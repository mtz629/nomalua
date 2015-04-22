NOMALUA.CheckTypes = {NETWORK = "NETWORK", DYNCODE = "DYNCODE",  AUTHENT = "AUTHENT", BANMGMT = "BANMGMT", FILESYS = "FILESYS", OBFUSC = "OBFUSC", MISC = "MISC" }

NOMALUA.PatternChecks = { 	
	{Pattern = "STEAM_[0-9]+:[0-9]+:[0-9]+", CheckType = NOMALUA.CheckTypes.AUTHENT, Desc = "Presence of Steam ID", Risk = 2},
	{Pattern = "http.Post", CheckType = NOMALUA.CheckTypes.NETWORK, Desc = "HTTP server call", Risk = 4},
	{Pattern = "http.Fetch", CheckType = NOMALUA.CheckTypes.NETWORK, Desc = "HTTP server call", Risk = 4},
	{Pattern = "CompileString", CheckType = NOMALUA.CheckTypes.DYNCODE, Desc = "Dynamic code execution", Risk = 2},
	{Pattern = "RunString", CheckType = NOMALUA.CheckTypes.DYNCODE, Desc = "Dynamic code execution", Risk = 2},
	{Pattern = "removeip", CheckType = NOMALUA.CheckTypes.BANMGMT, Desc = "Unban by IP address", Risk = 2},
	{Pattern = "removeid", CheckType = NOMALUA.CheckTypes.BANMGMT, Desc = "Unban by Steam ID", Risk = 2},
	{Pattern = "banip", CheckType = NOMALUA.CheckTypes.BANMGMT, Desc = "Ban by IP address", Risk = 2},
	{Pattern = "writeid", CheckType = NOMALUA.CheckTypes.BANMGMT, Desc = "Writing bans to disk", Risk = 1},
	{Pattern = "file.Read", CheckType = NOMALUA.CheckTypes.FILESYS, Desc = "Reading file contents", Risk = 1},
	{Pattern = "file.Delete", CheckType = NOMALUA.CheckTypes.FILESYS, Desc = "File deletion", Risk = 2},
	{Pattern = "0[xX][0-9a-fA-F]+", CheckType = NOMALUA.CheckTypes.OBFUSC, Desc = "Obfuscated / encrypted code", Risk = 3},
	{Pattern = "\\[0-9]+\\[0-9]+", CheckType = NOMALUA.CheckTypes.OBFUSC, Desc = "Obfuscated / encrypted code", Risk = 3},
	{Pattern = "\\[xX][0-9a-fA-F][0-9a-fA-F]", CheckType = NOMALUA.CheckTypes.OBFUSC, Desc = "Obfuscated / encrypted code", Risk = 3},
	
	{Pattern = "getfenv", CheckType = NOMALUA.CheckTypes.MISC, Desc = "Call to getfenv()", Risk = 1},
	{Pattern = "_G%[", CheckType = NOMALUA.CheckTypes.MISC, Desc = "References global table", Risk = 1},

	

}
