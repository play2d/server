local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.GETSTATEENTS] = function (Connection)
	local Index, Entity = next(Connection.EntityQueue)
	if Entity then
		Connection.EntityQueue[Index] = nil
	
		if Entity:IsValid() then
			local Data = Entity:GetNETData()
			local Encoded = json.encode(Data)
			
			local x, y = Entity:GetPosition()
			local Datagram = ("")
				:WriteShort(CONST.NET.SERVERTRANSFER)
				:WriteByte(CONST.NET.STAGE.GETSTATEENTS)
				:WriteInt24(Connection.EntityQueueSize)
				:WriteInt24(Entity:GetID())
				:WriteLine(Entity:GetClass())
				:WriteInt(x)
				:WriteInt(y)
				:WriteShort(Entity:GetAngle() + 360)
				:WriteInt24(#Encoded)
				:WriteString(Encoded)
			
			Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
		end
	else
		Connection.EntityQueue = nil
		Connection.EntityQueueSize = nil
		Connection.Stage = CONST.NET.STAGE.GETSTATEPLYS
		
		Connection.PlayerQueue = {}
		for ID, Player in pairs(Core.State.PlayersConnected) do
			table.insert(Connection.PlayerQueue, Player)
		end
		Connection.PlayerQueueSize = #Connection.PlayerQueue
	end
end