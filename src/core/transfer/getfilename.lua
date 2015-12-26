local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.GETFILENAME] = function (Connection)
	local CurrentTransfer
	for Index, File in pairs(Connection.Transfer) do
		Connection.Transfer[Index] = nil
		if File.Handle then
			CurrentTransfer = File
			break
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
			:WriteLine(CurrentTransfer.Path)
			:WriteInt(CurrentTransfer.Size)
			:WriteLine(CurrentTransfer.Checksum) -- MD5 hash
		
		print("Sending file '"..CurrentTransfer.Path.."' ("..CurrentTransfer.Size.." bytes)")
		
		Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
	else
		Connection.Stage = CONST.NET.STAGE.GETSTATEENTS
		Connection.Sync = true
		
		Connection.EntityQueue = {}
		for ID, Entity in pairs(Core.State.Entities) do
			table.insert(Connection.EntityQueue, Entity)
		end
		Connection.EntityQueueSize = #Connection.EntityQueue
	end
end