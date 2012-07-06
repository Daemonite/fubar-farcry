<cfcomponent extends="farcry.core.packages.types.farLog">

	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bAudit" type="boolean" required="false" hint="Set to false to disable logging" />
		
		<cfset var bLogToDB = true />
		<cfset var thiskey = "" />
		<cfset var couchLog = "" />
		
		<cfif listfindnocase("deprecated,create,delete,lock,update,loginfailed,login,movenode,toapproved,topending,todraft,createdraftobject",arguments.stProperties.event)>
			<cfset couchlog = application.fc.lib.error.collectRequestInfo() />
			
			<cfloop collection="#arguments.stProperties#" item="thiskey">
				<cfif thiskey eq "object">
					<cfset couchlog["object"] = arguments.stProperties.object />
					<cfset couchlog["objecttype"] = application.fapi.findType(arguments.stProperties.object) />
				<cfelseif thiskey eq "event">
					<cfset couchlog["message"] = arguments.stProperties.event />
				<cfelseif not listfindnocase("objectid,type",thiskey)>
					<cfset couchlog[lcase(thiskey)] = arguments.stProperties[thiskey] />
				</cfif>
			</cfloop>
			
			<cfset application.fc.lib.error.logToCouch(arguments.stProperties.type,couchLog) />
			
			<!--- Don't log events to db that aren't used in UI or logic --->
			<cfset bLogToDB = (listfindnocase("deprecated,create,delete,lock,update,movenode,createdraftobject",arguments.stProperties.event) eq 0) />
		</cfif>
		<!--- Events not logged to couch here: comment, 404, workflow events (task completion, completing workflow) --->
		
		<cfif bLogToDB>
			<cfif not structkeyexists(arguments.stProperties,"user") or not len(arguments.stProperties.user)>
				<cfset arguments.stProperties.user = "anonymous" />
			</cfif>
			
			<cfif structkeyexists(arguments.stProperties,"object") and len(arguments.stProperties.object) and (not structkeyexists(arguments.stProperties,"type") or not len(arguments.stProperties.type))>
				<cfset arguments.stProperties.type = findType(arguments.stProperties.object) />
			</cfif>
			
			<cfreturn super.createData(stProperties=arguments.stProperties,user=arguments.user,auditNote=arguments.auditNote,dsn=arguments.dsn,bAudit=false) />
		</cfif>
	</cffunction>
	
</cfcomponent>