local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.GETFILE] = function (Connection)
	local Part = Connection.CurrentTransfer.Handle:read(Connection.CurrentTransfer.Speed)
	if Part then
		local Datagram = ("")
			:WriteShort(CONST.NET.SERVERTRANSFER)
			:WriteByte(CONST.NET.STAGE.GETFILE)
			:WriteShort(#Part)
			:WriteString(Part)
			:WriteByte(Connection.CurrentTransfer.Handle:eof() and 1 or 0)
		
		Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
	else
		Connection.CurrentTransfer.Handle:close()
		Connection.CurrentTransfer = nil
		Connection.Stage = CONST.NET.STAGE.CONFIRM
	end
end