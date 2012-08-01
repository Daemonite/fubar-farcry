<cfsetting enablecfoutputonly="true" requesttimeout="100000" />
<!--- @@displayname: Fubar Purge --->

<cfparam name="url.keep" default="14" />
<cfparam name="url.timeout" default="300" />

<cfset startTime = getTickCount() />

<cfif len(application.config.cdb.db)>
	<cfhttp 
		url="http://#application.config.cdb.host#/#application.config.cdb.db#/_design/errorlog/_view/log-types" 
		port="#application.config.cdb.port#" 
		username="#application.config.cdb.username#" 
		password="#application.config.cdb.password#" timeout="60" />
	<cfset stResult = deserializeJSON(cfhttp.filecontent) />
	<cfset aLogTypes = stResult.rows[1].value />
	
	<cfhttp 
		url="http://#application.config.cdb.host#/#application.config.cdb.db#/config" 
		port="#application.config.cdb.port#" 
		username="#application.config.cdb.username#" 
		password="#application.config.cdb.password#" timeout="60" />
	<cfset stConfig = deserializeJSON(cfhttp.filecontent) />
	
	<cfloop from="1" to="#arraylen(stConfig.applications)#" index="k">
		<cfloop from="1" to="#arraylen(aLogTypes)#" index="i">
			<cfset startKey = arraynew(1) />
			<cfset startKey[1] = stConfig.applications[k].id />
			<cfset startKey[2] = aLogTypes[i] />
			<cfset startKey = urlencodedformat(replace(serializeJSON(startKey),',404.0',',"404"')) />
			
			<cfset endKey = arraynew(1) />
			<cfset endKey[1] = stConfig.applications[k].id />
			<cfset endKey[2] = aLogTypes[i] />
			<cfset endKey[3] = dateadd("d",0-stConfig.applications[k].history,now()) />
			<cfset endKey[3] = "#dateformat(endKey[3],'yyyy-mm-dd')#T#timeformat(endKey[3],'HH:mm:ss.000Z')#">
			<cfset endKey = urlencodedformat(replace(serializeJSON(endKey),',404.0',',"404"')) />
			
			<cfset go = true />
			
			<cfloop condition="go">
				
				<cfhttp 
					url="http://#application.config.cdb.host#/#application.config.cdb.db#/_design/errorlog/_view/logs-bytype?startkey=#startKey#&endkey=#endKey#&limit=1000&include_docs=true&update_seq=false" 
					port="#application.config.cdb.port#" 
					username="#application.config.cdb.username#" 
					password="#application.config.cdb.password#" />
				<cfset stResult = deserializeJSON(cfhttp.filecontent) />
				
				<cfif arraylen(stResult.rows)>
					<cfset stUpdate = structnew() />
					<cfset stUpdate["docs"] = arraynew(1) />
					<cfloop from="1" to="#arraylen(stResult.rows)#" index="j">
						<cfset st = structnew() />
						<cfset st["_id"] = stResult.rows[j].doc._id />
						<cfset st["_rev"] = stResult.rows[j].doc._rev />
						<cfset st["_deleted"] = true />
						<cfset arrayappend(stUpdate["docs"],st) />
					</cfloop>
					
					<cfhttp 
						url="http://#application.config.cdb.host#/#application.config.cdb.db#/_bulk_docs" 
						port="#application.config.cdb.port#" 
						username="#application.config.cdb.username#" 
						password="#application.config.cdb.password#" 
						method="POST">
						
						<cfhttpparam type="header" name="Content-Type" value="application/json" />
						<cfhttpparam type="body" value="#serializeJSON(stUpdate)#" />
					</cfhttp>
					
					<cfoutput>Deleted #stConfig.applications[k].name# #aLogTypes[i]# #stResult.rows[1].doc.datetimeorderable# - #stResult.rows[arraylen(stResult.rows)].doc.datetimeorderable#<br /></cfoutput>
					
					<cfif arraylen(stResult.rows) lt 1000>
						<cfset go = false />
					</cfif>
				<cfelse>
					<cfset go = false />
				</cfif>
				
				<cfif getTickCount() - startTime gt url.timeout * 1000>
					<cfbreak>
				</cfif>
			</cfloop>
			
			<cfif getTickCount() - startTime gt url.timeout * 1000>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>

<cfsetting enablecfoutputonly="false" />