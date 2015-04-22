-- client
if not NOMALUA then NOMALUA = {} end


include('sh_nomalua.lua')


net.Receive( "NomaluaConsoleMsg", function( len )
	local bits = net.ReadTable()
	NOMALUA.ConsoleRender(bits)
end )