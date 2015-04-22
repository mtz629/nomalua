Nomalua v1.31 (released 2015-04-22)


Nomalua is a malware scanner for GMod Lua files.  It scans Lua files on the server (including those mounted through Steam Workshop GMA files) and reports on any suspicious code or code patterns that may warrant further invesitgation. 

IT IS IMPORTANT to understand that detection by Nomalua does NOT necessarily mean you have a problem -- simply that a code construct or pattern exists that meets Nomalua's critera for reporting.  **The vast majority of alerts will be false positives**.  However, when you run an addon you are trusting that author to be a good citizen. Addons can harbor backdoors and other nefarious code.  It's better to trust but verify rather than simply trust blindly. Nomalua allows server administrators to have better insight into what's running without having to analyze every addon line-by-line. This is especially true as more server administrators use addons through the Steam Workshop, which makes it harder for admins to review code and track updates.


----------  DEVELOPER & SUPPORT  ----------

Nomalua was developed by BuzzKill.  Visit https://github.com/THABBuzzkill/nomalua for downloads, bug reports, support and release info.



----------  REQUIREMENTS  ----------

Nomalua has no requirements.



----------  INSTALLATION  ----------

To install Nomalua, simply extract the files from the archive to your garrysmod/addons folder.
When you've done this, you should have a file structure like this--
	<garrysmod>/addons/nomalua/lua/autorun/init.lua
	<garrysmod>/addons/nomalua/lua/sv_nomalua.lua
etc..


Please note that installation is the same on dedicated servers. Installation requires a server restart.



----------  USAGE  ----------

CONSOLE COMMANDS:



:::: nomalua scan ::::

Once installed and the server restarted, you can run the scanner by opening console and issuing the "nomalua scan" command.  If running directly on the server, you should immediately begin to see output (sample below).  If running through a client, you must have superadmin priviledges. When running through a client console there may be a delay before output is rendered. Nomalua is rather resource-intensive, so it's not recommended that you run it when the server is particularly busy. 

Example:	nomalua scan

Nomalua reports back the following (sample):

1	2 - AUTHENT (Presence of Steam ID)		gamemodes/jailbreak/gamemode/core/cl_menu_help_options.lua:218			: Excl (STEAM_0:0:19441588) - Lead developer in charge of Jail Break since version 1
2	4 - NETWORK (HTTP server call)			addons/hatschat2/lua/hatschat/cl_init.lua:196							http.Fetch( FUrl, function( body, len, header, code)
3	2 - BANMGMT (Ban by IP address)			addons/customcommands_onecategory/lua/ulx/modules/sh/cc_util.lua:283	local banip = ulx.command( "Custom", "ulx banip", ulx.banip )
4	2 - DYNCODE (Dynamic code execution)	lua/autorun/luapad.lua:152												RunString(file.Read("luapad/_server_globals.txt", "DATA"));
5	2 - FILESYS (File deletion) 			addons/customcommands_onecategory/lua/ulx/modules/sh/cc_util.lua:909	file.Delete( "watchlist/" .. id .. ".txt" )
6	3 - OBFUSC (Obfuscated / encrypted code)	lua/includes/extensions/string.lua:34								str = str:gsub( "\226\128\168", "\\\226\128\168" )

The first column is simply the sequence (ID) number of the scan entry. This can be used when adding whitelist items.

The second column contains the risk rating, check type and description.  Currently, Nomalua detects dynamic code (code that executes dynamically, using compilestring, etc), authentication checks (references to Steam IDs), network activity (calls to http.Post and Fetch), ban related items (changes in ban status), obfuscated code (bytecode, encryption) and file system calls (file deletions). The risk rating is from 1 through 5, 5 being the highest.  Currently the rating system is rather arbitrary -- it will be firmed up over time.

The third column points to the file and line number of the detection.  Note that if this addon is contained within in a GMA, you will need to manually decompress the .gma file in order to view the file directly.

The fourth column shows the line itself, with the detection phrase highlighted in yellow.



:::: nomalua dumpfile <filepath> ::::

This command will dump the contents of a file to console for further investigation.
Example:	nomalua dumpfile addons/customcommands_onecategory/lua/ulx/modules/sh/cc_util



:::: nomalua whitelist ::::

Dumps the current whitelist to console.
Example:	nomalua whitelist



:::: nomalua addwl <scan entry id> ::::

Adds a whitelist entry that corresponds to a scan item. For example, from the sample scan output above, if we wanted to add a whitelist for item #4 (Luapad's dynamic code), the command would be...
Example:	nomalua wladd 4

Optionally, whitelist entries can be added fully verbosely, including filename, line number and type.
Example:	nomalua wladd lua/includes/extensions/string.lua 34 OBFUSC



:::: nomalua delwl <whitelist entry id> ::::

Deletes the whitelist entry corresponding to the whitelist entry ID number.
Example:	nomalua delwl 3



:::: nomalua lastscan ::::

Simply re-displays the results of the most recent scan.
Example:	nomalua lastscan






----------  CONFIGURATION  ----------

Whitelisting (beta):  Whitelisting is currently managed in the sv_nomalua_whitelist.lua file, specifically via calls to NOMALUA.AddWhiteListElement, which takes 3 parameters.  The first parameter in the call is a Lua pattern  (see http://lua-users.org/wiki/PatternsTutorial for a tutorial in Lua patterns).  The second parameter is the line number (0 to match all), and the third is the detection group ("*" to match all). Whitelisting is currently Beta and will be moved to a proper data file in a future release.

Whitelist samples:

	NOMALUA.AddWhiteListElement("addons/nomalua/lua/sv_nomalua.lua", 0, "*")   			-- prevents Nomalua from reporting on its own pattern checks
	NOMALUA.AddWhiteListElement("addons/cac%-release%-.*.lua", 0, "*")					-- ignores Cake Anti-cheat
	NOMALUA.AddWhiteListElement("addons/ulib/lua/ulib/server/player.lua", 0, "BANMGMT")	-- Ignores ban related items in ULib's player.lua
	


----------  CHANGELOG  ----------

v1.31 - *(2015-04-22)*
	* Delete whitelist entries
	* Add whitelist entries verbosely

v1.30 - *(2015-04-22)*
	* New console command structure
	* Added ability to add whitelist items
	* Added ability to dump individual files to console
	* Ability to re-display previous scan results

v1.20 - *(2015-04-21)*
	* Added risk rank (currently 1 - 5, 5 highest.  Rather arbitrary for now.  Still beta. Hell, the whole thing is still beta)
	* Optimized check type and pattern check definition code
	* Fixed bug in directory recursion code
	* misc minor optimizations
	* Added additional pattern checks

v1.11 - *(2015-04-20)*
	* Bug fix.  AddLuaFiles returning nil under certain conditions, causing scan to error out.
	
v1.10 - *(2015-04-20)*
	* Adjusted directory recursion logic to prepend root search directory
	* Added whitelisting and some default whitelist items
	* Restructured lua file search so that matching files in addons/<addonname>/lua/... and lua/... purposely collide in storage table (de-dupe)
	* Refactored scan to queue output, eliminating need to pass ply var around.

v1.00 - *(2015-04-19)*
	* Initial version

	

----------  LICENSE  ----------

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to
Creative Commons
543 Howard Street
5th Floor
San Francisco, California 94105
USA



(what the heck does "nomalua" mean?  No-Mal-Lua. Get it?  Don't worry - the code is better than the name.  :)  )