<cfcomponent displayname="Couch Error Log" hint="Settings for logging errors to a Couch DB" extends="farcry.core.packages.forms.forms" output="false" key="cdb">
	
	<cfproperty name="host" type="string" default="127.0.0.1"
				ftSeq="1" ftFieldSet="Logging" ftLabel="Host" />
	
	<cfproperty name="port" type="string" default="5984"
				ftSeq="2" ftFieldSet="Logging" ftLabel="Port" />
	
	<cfproperty name="db" type="string" default=""
				ftSeq="3" ftFieldSet="Logging" ftLabel="Database" />
	
	<cfproperty name="username" type="string" default=""
				ftSeq="4" ftFieldSet="Logging" ftLabel="Username" />
	
	<cfproperty name="password" type="string" default=""
				ftSeq="5" ftFieldSet="Logging" ftLabel="Password" />
	
	
	<cfproperty name="hostNotifications" type="string" default="127.0.0.1"
				ftSeq="11" ftFieldSet="Notifications" ftLabel="Host" />
	
	<cfproperty name="portNotifications" type="string" default="5984"
				ftSeq="12" ftFieldSet="Notifications" ftLabel="Port" />
	
	<cfproperty name="dbNotifications" type="string" default=""
				ftSeq="13" ftFieldSet="Notifications" ftLabel="Database" />
	
	<cfproperty name="usernameNotifications" type="string" default=""
				ftSeq="14" ftFieldSet="Notifications" ftLabel="Username" />
	
	<cfproperty name="passwordNotifications" type="string" default=""
				ftSeq="15" ftFieldSet="Notifications" ftLabel="Password" />
	
</cfcomponent>