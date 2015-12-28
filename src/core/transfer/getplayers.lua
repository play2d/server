local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.GETSTATEPLYS] = function (Connection)
	local Index, Player = next(Connection.PlayerQueue)
	if Player then
		Connection.PlayerQueue[Index] = nil
		
		Datagram = ("")
			:WriteShort(CONST.NET.SERVERTRANSFER)
			:WriteByte(CONST.NET.STAGE.GETSTATEPLYS)
			:WriteByte(Connection.PlayerQueueSize)
			:WriteByte(Player.ID)
			:WriteLine(Player.Code)
			:WriteLine(Player.Name)
			:WriteNumber(Player.Score)
			:WriteNumber(Player.Kills)
			:WriteNumber(Player.Deaths)
		
		Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
	else
		Connection.PlayerQueue = nil
		Connection.PlayerQueueSize = nil
		Connection.Stage = CONST.NET.STAGE.GETSTATECVARS
		
		Connection.CVarQueue = {}
		for CVarName, CVar in pairs(Core.State.ConVars) do
			if CVar.SendToClient == ffi.TRUE then
				table.insert(Connection.CVarQueue, Player)
			end
		end
		Connection.CVarQueueSize = #Connection.CVarQueue
	end
end