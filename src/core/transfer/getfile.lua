local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.GETFILE] = function (Connection)
	local Part = Connection.CurrentTransfer.Handle:read(Connection.CurrentTransfer.Speed) or ""
	local Eof = Connection.CurrentTransfer.Handle:eof()
	local Datagram = ("")
		:WriteShort(CONST.NET.SERVERTRANSFER)
		:WriteByte(CONST.NET.STAGE.GETFILE)
		:WriteShort(#Part)
		:WriteString(Part)
		:WriteByte(Eof and 1 or 0)
		
	Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
	
	if Eof then
		Connection.CurrentTransfer.Handle:close()
		Connection.CurrentTransfer = nil
		Connection.Stage = CONST.NET.STAGE.CONFIRM
	end
end