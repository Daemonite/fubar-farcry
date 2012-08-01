<cfsetting enablecfoutputonly="true" requesttimeout="300" />
<!--- @@displayname: Fubar Alerts --->

<cfimport taglib="/farcry/core/tags/misc" prefix="misc" />

<!--- Get config - this contains list of applications and who wants notifications --->
<cfhttp url="http://#application.config.cdb.hostNotifications#/#application.config.cdb.dbNotifications#/config" 
	port="#application.config.cdb.portNotifications#" 
	method="GET" 
	username="#application.config.cdb.usernameNotifications#" 
	password="#application.config.cdb.passwordNotifications#"
	timeout="10">
</cfhttp>
<cfset stConfig = deserializeJSON(cfhttp.filecontent) />

<cfset stUsers = structnew() />

<cfset startTime = dateformat(now(),"yyyy-mm-dd") & " " & timeformat(now(),"HH:") & numberformat(int(minute(dateadd("n",-15,now()))/15)*15,"00") />
<cfset endTime = dateformat(now(),"yyyy-mm-dd") & " " & timeformat(now(),"HH:") & numberformat(int(minute(now())/15)*15,"00") />

<cfparam name="application.fubar" default="#structnew()#" />
<cfparam name="application.fubar.lastreported" default="#structnew()#" />

<cfset lastreported = application.fubar.lastreported />
<cfset application.fubar.lastreported = structnew() />

<cfif structkeyexists(stConfig,"applications")>
	<cfloop from="1" to="#arraylen(stConfig.applications)#" index="i">
		<cfif structkeyexists(stConfig.applications[i],"access")>
			<cfset stTargets = structnew() />
			<cfloop from="1" to="#arraylen(stConfig.applications[i].access)#" index="j">
				<cfif structkeyexists(stConfig.applications[i].access[j],"sendalerts") and stConfig.applications[i].access[j].sendalerts>
					<cfif not structkeyexists(stUsers,stConfig.applications[i].access[j].userid)>
						
						<!--- Get user's information --->
						<cfhttp url="http://#application.config.cdb.hostNotifications#/_users/#urlencodedformat('org.couchdb.user:' & stConfig.applications[i].access[j].userid)#" 
							port="#application.config.cdb.portNotifications#" 
							method="GET" 
							username="#application.config.cdb.usernameNotifications#" 
							password="#application.config.cdb.passwordNotifications#"
							timeout="10">
						</cfhttp>
						<cfset stUsers[stConfig.applications[i].access[j].userid] = deserializeJSON(cfhttp.filecontent) />
						
					</cfif>
					
					<!--- Add user to the target list for this app --->
					<cfset stTargets[stConfig.applications[i].access[j].userid] = structnew() />
					<cfset stTargets[stConfig.applications[i].access[j].userid].threshold = stConfig.applications[i].access[j].threshold />
					<cfset stTargets[stConfig.applications[i].access[j].userid].errors = arraynew(1) />
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- We have found people who want alerts for this application --->
		<cfif not structisempty(stTargets)>
			<!--- Get application error information --->
			<cfset startkey = arraynew(1) />
			<cfset arrayappend(startkey,startTime) />
			<cfset arrayappend(startkey,stConfig.applications[i].id) />
			
			<cfset endkey = arraynew(1) />
			<cfset arrayappend(endkey,startTime) />
			<cfset arrayappend(endkey,stConfig.applications[i].id & "_") />
			
			<cfhttp url="http://#application.config.cdb.host#/#application.config.cdb.db#/_design/errorlog/_view/logerrors-by15min?startkey=#urlencodedformat(serializeJSON(startKey))#&endkey=#urlencodedformat(serializeJSON(endKey))#&group=true" 
				port="#application.config.cdb.port#" 
				method="GET" 
				username="#application.config.cdb.username#" 
				password="#application.config.cdb.password#"
				timeout="10">
			</cfhttp>
			<cfset stResult = deserializeJSON(cfhttp.filecontent) />
			
			<!--- Check each target threshold, and add the error to the appropriate arrays --->
			<cfloop from="1" to="#arraylen(stResult.rows)#" index="j">
				<cfloop collection="#stTargets#" item="targetid">
					<cfif stTargets[targetid].threshold lt stResult.rows[j].value>
						<cfset application.fubar.lastreported[stResult.rows[j].key[2] & stResult.rows[j].key[3]] = true />
						<cfif not structkeyexists(lastreported,stResult.rows[j].key[2] & stResult.rows[j].key[3])>
							<cfset arrayappend(stTargets[targetid].errors,"#stResult.rows[j].value# - #stResult.rows[j].key[3]#") />
						</cfif>
					</cfif>
				</cfloop>
			</cfloop>
			
			<!--- Send notifications --->
			<cfloop collection="#stTargets#" item="targetid">
				<cfif arraylen(stTargets[targetid].errors)>
					<misc:sort values="#stTargets[targetid].errors#">
						<cfset sendback = listfirst(value2," ") - listfirst(value1," ") />
					</misc:sort>
					
					<cfset title = stConfig.applications[i].name & " Errors" />
					<cfset text = "" />
					<cfloop from="1" to="#arraylen(result)#" index="i">
						<cfif not len(title) + len(text) + len(left(result[i],50)) + 4 gt 512>
							<cfset text = listappend(text,left(result[i],50),", ") />
						</cfif>
					</cfloop>
					<cfset text = rereplace(text,",(\d)",", \1","ALL") />
					<cfset html = arraytolist(result,"<br>") />
					
					<cfswitch expression="#stUsers[targetid].targettype#">
						<cfcase value="email">
							<cfmail to="#stUsers[targetid].targetid#" from="#application.config.general.adminemail#" subject="#stConfig.applications[i].name# Error Alert [#startTime# - #endTime#]" type="plain"><cfoutput>#text#</cfoutput></cfmail>
						</cfcase>
						
						<cfcase value="pushover">
							<cfhttp url="https://api.pushover.net/1/messages.json" method="POST">
								<cfhttpparam type="formfield" name="token" value="6f1JZwJcqDwJEmZbHi82FHYdW8HO7C" />
								<cfhttpparam type="formfield" name="user" value="#stUsers[targetid].targetid#" />
								<cfhttpparam type="formfield" name="title" value="#title#" />
								<cfhttpparam type="formfield" name="message" value="#text#" />
							</cfhttp>
						</cfcase>
					</cfswitch>
					
					<cfoutput>Notified #stUsers[targetid].targetid# [#targetid#] of #stConfig.applications[i].name# errors:<br>#html#<br><br></cfoutput>
				</cfif>
			</cfloop>
		</cfif>
	</cfloop>
</cfif>

<cfsetting enablecfoutputonly="false" />