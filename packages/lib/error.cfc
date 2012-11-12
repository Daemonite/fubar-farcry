<cfcomponent extends="farcry.core.packages.lib.error" output="false">
	
	<cffunction name="collectRequestInfo" access="public" returntype="struct" output="false" hint="Returns a struct containing information that should be included in every error report">
		<cfset var stResult = super.collectRequestInfo() />
		<cfset var headers = GetHttpRequestData().headers />
		
		<cfif structkeyexists(headers,"X-User-Agent")>
			<cfset stResult["browser"] = headers["X-User-Agent"] />
		</cfif>
		<cfif structkeyexists(headers,"X-Forwarded-For")>
			<cfset stResult["remoteaddress"] = trim(listfirst(headers["X-Forwarded-For"])) />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="logToCouch" access="public" output="false" returntype="void" hint="Logs data to the couchdb">
		<cfargument name="type" type="string" required="true" hint="Log type" />
		<cfargument name="data" type="struct" requried="true" hint="Log data" />
		
		<cfif isdefined("application.config.cdb.host") and len(application.config.cdb.host) 
			and isdefined("application.config.cdb.port") and len(application.config.cdb.port)
			and isdefined("application.config.cdb.db") and len(application.config.cdb.db)>
			
			<cfset arguments.data = duplicate(arguments.data) />
			
			<cfset arguments.data["logtype"] = arguments.type />
			<cfset arguments.data["application"] = application.applicationname />
			<cfif isdefined("application.sysinfo.version")>
				<cfset arguments.data["farcry"] = application.sysinfo.version />
			</cfif>
			<cfif isdefined("application.sysinfo.engine")>
				<cfset arguments.data["engine"] = application.sysinfo.engine />
			</cfif>
            <cfif isdefined("application.sessionid")>
            	<cfset arguments.data["sessionid"] = session.sessionID />
            </cfif>
			<cfset arguments.data["datetimeorderable"] = dateformat(arguments.data.datetime,"yyyy-mm-dd") & " " & timeformat(arguments.data.datetime,"HH:mm:ss") />
			<cfset arguments.data["datetime"] = dateformat(arguments.data["datetime"],"mmmm, dd yyyy") & " " & timeformat(arguments.data["datetime"],"HH:mm:ss")>
			
			
			<cfhttp url="http://#application.config.cdb.host#/#application.config.cdb.db#" 
					port="#application.config.cdb.port#" 
					method="POST" 
					username="#application.config.cdb.username#" 
					password="#application.config.cdb.password#"
					timeout="0">
				
				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="body" value="#serializeJSON(arguments.data)#">
				
			</cfhttp>
			
		</cfif>
	</cffunction>
	
	
	<cffunction name="create404Error" access="public" returntype="struct" output="false" hint="Constructs a 404 error struct">
		<cfset var stError = super.create404Error(argumentCollection=arguments) />
		
		<cfset logToCouch("404",stError) />
		
		<cfreturn stError />
	</cffunction>
	
	<cffunction name="logData" access="public" output="false" returntype="void" hint="Logs error to application and exception log files">
		<cfargument name="log" type="struct" required="true" />
		<cfargument name="bApplication" type="boolean" required="false" default="true" />
		<cfargument name="bException" type="boolean" required="false" default="true" />
		<cfargument name="bCouch" type="boolean" required="false" default="true" />
		
		<cfset var errorJSON = "" />
		<cfset var logtype = "error" />
		
		<cfif structkeyexists(arguments.log,"logtype")>
			<cfset logtype = arguments.log.logtype />
			<cfset structdelete(arguments.log,"logtype") />
		</cfif>
		
		<cfset logToCouch(logtype,arguments.log) />
		
		<cfset super.logData(argumentCollection=arguments) />
	</cffunction>
	
</cfcomponent>