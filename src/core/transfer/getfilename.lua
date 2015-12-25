local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.GETFILENAME] = function (Connection)
	local CurrentTransfer
	for Index, File in pairs(Connection.Transfer) do
		Connection.Transfer[Index] = nil
		if File.Handle then
			CurrentTransfer = File
		end
	end
	
	if CurrentTransfer then
		Connection.CurrentTransfer = {
			Handle = CurrentTransfer.Handle,
			Path = CurrentTransfer.Path,
			Size = CurrentTransfer.Size,
			Checksum = CurrentTransfer.Checksum,
			Speed = 500,
		}
		Connection.Stage = CONST.NET.STAGE.GETFILE
		
		local Datagram = ("")
			:WriteShort(CONST.NET.SERVERTRANSFER)
			:WriteByte(CONST.NET.STAGE.GETFILENAME)
			:WriteLine(Current.Transfer.Path)
			:WriteInt(Current.Transfer.Size)
			:WriteLine(Current.Transfer.Checksum) -- MD5 hash
		Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
	else
		Connection.Stage = CONST.NET.STAGE.GETSTATEENTS
		
		Connection.EntityQueue = {}
		for ID, Entity in pairs(Core.State.Entities) do
			table.insert(Connection.EntityQueue, Entity)
		end
		Connection.EntityQueueSize = #Connection.EntityQueue
	end
end