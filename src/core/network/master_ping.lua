-- Sometimes the router blocks the server's ports, so we're going to use this to unblock connections

local MasterServerAddress = ""

Core.Network.Protocol[CONST.NET.PINGHOST] = function (Peer, Message)
	if tostring(Peer) == MasterServerAddress then
		local Address = Message:ReadLine()
		
		Core.Network.Host:connect(Address, CONST.NET.CHANNELS.MAX)
	end
end

local File = io.open("sys/masterserver.cfg", "r")
if File then
	MasterServerAddress = File:read("*l")
	File:close()
end