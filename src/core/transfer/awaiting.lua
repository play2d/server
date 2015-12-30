local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.AWAIT] = function (Connection)
	Connection.Stage = CONST.NET.STAGE.JOIN
	
	local Datagram = ("")
		:WriteShort(CONST.NET.SERVERTRANSFER)
		:WriteByte(CONST.NET.STAGE.AWAIT)
		:WriteInt(Connection.ID)
		:WriteLine(Connection.Name)
		:WriteLine(Core.State.Mode)
		:WriteLine(Core.State.Map.Path)
	
	Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
end