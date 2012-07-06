<cfcomponent displayname="Couch Error Log" hint="Settings for logging errors to a Couch DB" extends="farcry.core.packages.forms.forms" output="false" key="cdb">
	
	<cfproperty name="host" type="string" default="127.0.0.1"
				ftSeq="1" ftLabel="Host" />
	
	<cfproperty name="port" type="string" default="5984"
				ftSeq="2" ftLabel="Port" />
	
	<cfproperty name="db" type="string" default=""
				ftSeq="3" ftLabel="Database" />
	
	<cfproperty name="username" type="string" default=""
				ftSeq="4" ftLabel="Username" />
	
	<cfproperty name="password" type="string" default=""
				ftSeq="5" ftLabel="Password" />
	
</cfcomponent>