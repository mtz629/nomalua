-- Version 1.2 Changelog
-- * Added risk rank (currently 1 - 5, 5 highest.  Rather arbitrary for now.  Still beta. Hell, the whole thing is still beta)
-- * Optimized check type and pattern check definition code
-- * Fixed bug in directory recursion code
-- * misc minor optimizations
-- * Added additional pattern checks


-- Version 1.1 Changelog
-- * Adjusted directory recursion logic to prepend root search directory
-- * Added whitelisting and some default whitelist items
-- * Restructured lua file search so that matching files in addons/<addonname>/lua/... and lua/... purposely collide in storage table (de-dupe)
-- * Refactored scan to queue output, eliminating need to pass ply var around.

if not NOMALUA then
	NOMALUA = {}
	NOMALUA.ScanResults = {}
	NOMALUA.Whitelist = {}
end

include('sh_nomalua.lua')
include('sv_nomalua_utils.lua')
include('sv_nomalua_checkdefs.lua')
include('sv_nomalua_whitelist.lua')

util.AddNetworkString( "NomaluaConsoleMsg" )


function NOMALUA.SaveWhitelist()
	local tab = util.TableToJSON( NOMALUA.Whitelist, true )
	file.CreateDir( "nomalua" ) -- Create the directory
	file.Write( "nomalua/whitelist.txt", tab )
end


local wlcontent = file.Read( "nomalua/whitelist.txt", "DATA" )
if (wlcontent != nil) then
	NOMALUA.Whitelist = util.JSONToTable( wlcontent )
else
	NOMALUA.AddDefaultWhiteListElements()
	NOMALUA.SaveWhitelist()
end


function NOMALUA.IsWhitelisted(filename, linenum, checktype)
	for k,whiteitem in pairs(NOMALUA.Whitelist) do
		if (string.match(filename, whiteitem.file) and 
			(whiteitem.line == linenum or whiteitem.line == 0) and 
			(whiteitem.check == checktype or whiteitem.check == "*")) then
			return true
		end
	end
	return false
end


--- standardized check for presence of token in string
function NOMALUA.PatternCheck(src, filename, linenum, patternCheck)
	local result = string.match(src, patternCheck.Pattern)
	if (result != nil and not NOMALUA.IsWhitelisted(filename, linenum, patternCheck.CheckType)) then
		v = {}
		v.Src = src
		v.Filename = filename
		v.Linenum = linenum
		v.CheckType = patternCheck.CheckType
		v.Pattern = patternCheck.Pattern
		v.Desc = patternCheck.Desc
		v.Risk = patternCheck.Risk
		v.Tofind = result
		
		table.insert(NOMALUA.ScanResults, v)
	end
end

--- main loop
function NOMALUA.CheckFiles()
	local luaFiles = {}
	luaFiles = NOMALUA.AddLuaFiles(luaFiles, "lua", true)
	luaFiles = NOMALUA.AddLuaFiles(luaFiles, "addons", true) -- always run addons *after* lua, to support deduplication check
	luaFiles = NOMALUA.AddLuaFiles(luaFiles, "gamemodes", true)

	for k,filename in pairs(luaFiles) do
		local content = file.Read( filename, "GAME" )

		if (content != nil) then

			content = string.gsub(content, "\r", "")  -- better way to handle win eol?
			local content_lns = NOMALUA.split(content,"\n") -- split source into lines
			for linenum,linesrc in pairs(content_lns) do
			
				linesrc = string.Trim(linesrc)
				if string.Left(linesrc,2) != "--" and string.Left(linesrc,2) != "//" then -- not a rem statement
				
					for _, patternCheck in pairs (NOMALUA.PatternChecks) do
						NOMALUA.PatternCheck(linesrc, filename, linenum, patternCheck)
					end
				end
			end
		end
	end
end

function NOMALUA.OutputResults(ply)
	for k,output_value in pairs(NOMALUA.ScanResults) do
		NOMALUA.RenderNotice(k, output_value, ply)
	end
end

function NOMALUA.StartScan(ply)
	NOMALUA.ScanResults = {}
	NOMALUA.SendNotice ( {"[Nomalua] Initiating scan!\n"} , ply)
	NOMALUA.CheckFiles()
	NOMALUA.SendNotice ( {"[Nomalua] Scan complete!\n"} , ply)
	NOMALUA.OutputResults(ply)
	NOMALUA.SendNotice ( {"[Nomalua] Output complete!\n"} , ply)
end

function NOMALUA.DumpFile(ply, filename)
	local content = file.Read( filename, "GAME" )
	if (content != nil) then
		content = string.gsub(content, "\r", "")  -- better way to handle win eol?
		local content_lns = NOMALUA.split(content,"\n") -- split source into lines
		for linenum,linesrc in pairs(content_lns) do
			NOMALUA.SendNotice ( {linesrc, "\n"} , ply)
		end
	end
end

function NOMALUA.ShowWhitelist(ply)
	for linenum,ele in pairs(NOMALUA.Whitelist) do
		NOMALUA.SendNotice ( {linenum, "\t", ele.file,"\t", ele.line, "\t", ele.check, "\n"} , ply)
	end
end


function NOMALUA.AddWhiteListItem(ply,itemid)
	local scanItem = NOMALUA.ScanResults[itemid]
	if (scanItem == nil) then
		NOMALUA.SendNotice ( {"Could not locate a scan item for id "..itemid, "\n"} , ply)
	else
		table.insert(NOMALUA.Whitelist, {file=scanItem.Filename, line=scanItem.Linenum, check=scanItem.CheckType})
		NOMALUA.SaveWhitelist()
		NOMALUA.SendNotice ( {"Whitelist item added\n"} , ply)
	end
end


function NOMALUA.AddWhiteListItem2(ply,filename, linenum, checktype)
	table.insert(NOMALUA.Whitelist, {file=filename, line=linenum, check=checktype})
	NOMALUA.SaveWhitelist()
	NOMALUA.SendNotice ( {"Whitelist item added\n"} , ply)
end

function NOMALUA.DelWhiteListItem(ply,itemid)
	local wlItem = NOMALUA.Whitelist[itemid]
	if (wlItem == nil) then
		NOMALUA.SendNotice ( {"Could not locate a whitelist item for id "..itemid, "\n"} , ply)
	else
		table.remove(NOMALUA.Whitelist, itemid)
		NOMALUA.SaveWhitelist()
		NOMALUA.SendNotice ( {"Whitelist item deleted\n"} , ply)
	end
end


concommand.Add( "nomalua_scan", function( ply )
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:PrintMessage(HUD_PRINTCONSOLE, "[Nomalua] Only superadmins or console can launch a Nomalua scan")
	else
		NOMALUA.StartScan(ply)
	end
end )

concommand.Add( "nomalua", function( ply, cmd, args )
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:PrintMessage(HUD_PRINTCONSOLE, "[Nomalua] Only superadmins or console can launch Nomalua")
	else
		if (args[1] == "scan") then
			NOMALUA.StartScan(ply)
		elseif (args[1] == "dumpfile") then
			NOMALUA.DumpFile(ply, args[2])
		elseif (args[1] == "whitelist") then
			NOMALUA.ShowWhitelist(ply)
		elseif (args[1] == "lastscan") then
			NOMALUA.OutputResults(ply)
		elseif (args[1] == "addwl") then
			if (#args > 2) then
				NOMALUA.AddWhiteListItem2(ply,args[2],tonumber(args[3]), args[4])
			else
				NOMALUA.AddWhiteListItem(ply,tonumber(args[2]))
			end
		elseif (args[1] == "delwl") then
			NOMALUA.DelWhiteListItem(ply,tonumber(args[2]))
		end
		
	end
end )



