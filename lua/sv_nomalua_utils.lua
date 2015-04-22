if not NOMALUA then NOMALUA = {} end


function NOMALUA.ParseSmallKey( key )
	_,_, smallkey = string.find(key, "addons[%/][^%/]+[%/](.+)")
	return smallkey
end

function NOMALUA.AddLuaFiles( luaFilesTable, dir, recurse, root )
	
	if not file.IsDir(dir, "GAME") then
		return luaFilesTable
	end

	root = root or dir

	local result, dirs = file.Find( dir .. "/*", "GAME" )
	for i=1, #result do
		if (string.Right(result[ i ],4) == ".lua") then
		
			-- filter out any addons/... files we already included in lua/...
			-- for example, addons/myaddon/lua/file.lua and lua/file.lua will both appear.
			-- remove lua/file.lua  (overwrite the key wit the addons/.. value
			
			local key = dir .. "/" .. result[ i ]
			if (root == "addons") then
				key = NOMALUA.ParseSmallKey(key)
			end
	
			luaFilesTable[key] = dir .. "/" .. result[ i ] -- todo, change value to a bit
		end
	end

	for i=1, #dirs do
		luaFilesTable = NOMALUA.AddLuaFiles( luaFilesTable, dir .. "/" .. dirs[ i ], recurse, root ) 
	end

	return luaFilesTable
end

function NOMALUA.split(str, delim)
    local res = {}
    local pattern = string.format("([^%s]+)%s", delim, delim)
    for line in str:gmatch(pattern) do
        table.insert(res, line)
    end
    return res
end

function NOMALUA.trim1(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function NOMALUA.SendNotice (msgelements, ply)
	if (not IsValid(ply)) then
		NOMALUA.ConsoleRender( msgelements )
	else
		net.Start( "NomaluaConsoleMsg" )
		net.WriteTable( msgelements )
		net.Send( ply )
	end
end

--- pretty print to console
function NOMALUA.RenderNotice(linenum, v, ply)

	
	local msgelements = {linenum, "\t",  Color(255,165,0), v.Risk .. " - " .. v.CheckType.." ("..v.Desc..")", "\t\t", Color(0,255,255), v.Filename..":", Color(0,255,255), v.Linenum, "\t\t" }
	NOMALUA.SendNotice (msgelements, ply)
	
	local startpos,endpos = string.find(v.Src, v.Tofind,1,true)
	local lefts = string.Left(v.Src, startpos - 1)
	local rights = string.Right(v.Src, string.len(v.Src) - endpos)
	
	msgelements = { Color(255,255,255), lefts, Color(255,255,0), v.Tofind, Color(255,255,255), rights, "\n" }
	NOMALUA.SendNotice (msgelements, ply)
	
end