Hook.Create("PlayerConsole")

Core.Network.Protocol[CONST.NET.PLAYERCMD] = function (Peer, Message)
	local Command, Message = Message:ReadLine()
	local Connection = Core.Network.FindConnected(Peer)
	
	if Player then
		Hook.Call("PlayerConsole", Connection.ID, Command)
	end
end