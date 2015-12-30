local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.GETSTATECVARS] = function (Connection)
	local Index, CVar = next(Connection.CVarQueue)
	if CVar then
		Connection.CVarQueue[Index] = nil
		
		local CVarString = CVar:GetString()
		
		local Datagram = ("")
			:WriteShort(CONST.NET.SERVERTRANSFER)
			:WriteByte(CONST.NET.STAGE.GETCVARS)
			:WriteByte(Connection.CVarQueueSize)
			:WriteLine(CVar:GetName())
			:WriteShort(#CVarString)
			:WriteString(CVarString)
		
		Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
	else
		Connection.Stage = CONST.NET.STAGE.AWAIT
	end
end