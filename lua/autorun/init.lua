if SERVER then
	AddCSLuaFile()
	AddCSLuaFile('cl_nomalua.lua')
	AddCSLuaFile('sh_nomalua.lua')

	include('sv_nomalua.lua')
	
	print("[Nomalua] ------ Nomalua v1.30 (by BuzzKill) loaded! ------")
end

if CLIENT then
	include('cl_nomalua.lua')
end