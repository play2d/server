Hook.Create("PlayerConsole")

Core.Network.Protocol[CONST.NET.PLAYERCMD] = function (Peer, Message)
	local Command, Message = Message:ReadLine()
	local Address = tostring(Peer)
	local Player = Core.State.PlayersConnected[Address]
	
	if Player then
		Hook.Call("PlayerConsole", Address, Command)
	end
end