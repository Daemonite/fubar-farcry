<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry CMS Plugin.

    FarCry CMS Plugin is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry CMS Plugin is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with FarCry CMS Plugin.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">
	
	<cfset this.name = "Fubar" />
	<cfset this.description = "<strong>Fubar</strong> logs errors, 404s, and audit records to a couch database." />
	<cfset this.lRequiredPlugins = "" />
	<cfset addSupportedCore(majorVersion="6", minorVersion="2", patchVersion="0") />
	

</cfcomponent>

