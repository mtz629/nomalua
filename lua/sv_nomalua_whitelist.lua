
function NOMALUA.AddWhiteListElement(filename, linenum, checktype)
	table.insert(NOMALUA.Whitelist, {file=filename, line=linenum, check=checktype})
end


function NOMALUA.AddDefaultWhiteListElements()

	-- remove false positives from own check code
	NOMALUA.AddWhiteListElement("addons/nomalua/lua/sv_nomalua_checkdefs.lua", 0, "*")

	-- CAC false positives
	NOMALUA.AddWhiteListElement("addons/cac%-release%-.*.lua", 0, "*")

	-- ULB/ULX false positives
	NOMALUA.AddWhiteListElement("addons/ulib/lua/ulib/server/player.lua", 0, NOMALUA.CheckTypes.BANMGMT)

	NOMALUA.AddWhiteListElement("gamemodes/sandbox/entities/weapons/gmod_tool/stools/wheel.lua", 274, NOMALUA.CheckTypes.OBFUSC)
	NOMALUA.AddWhiteListElement("gamemodes/sandbox/entities/weapons/gmod_tool/stools/wheel.lua", 275, NOMALUA.CheckTypes.OBFUSC)
	NOMALUA.AddWhiteListElement("gamemodes/sandbox/entities/weapons/gmod_tool/stools/wheel.lua", 276, NOMALUA.CheckTypes.OBFUSC)
	NOMALUA.AddWhiteListElement("gamemodes/sandbox/entities/weapons/gmod_tool/stools/wheel.lua", 277, NOMALUA.CheckTypes.OBFUSC)
	NOMALUA.AddWhiteListElement("gamemodes/sandbox/entities/weapons/gmod_tool/stools/wheel.lua", 278, NOMALUA.CheckTypes.OBFUSC)

end

