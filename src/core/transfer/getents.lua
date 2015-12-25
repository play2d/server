local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.GETSTATEENTS] = function (Connection)
	local Datagram = ("")
		:WriteShort(CONST.NET.SERVERTRANSFER)
		:WriteByte(CONST.NET.STAGE.GETSTATEENTS)
		
	local Index, Entity = next(Connection.EntityQueue)
	if Entity then
		Connection.EntityQueue[Index] = nil
		
		local Data = Entity:GetNETData()
		local Encoded = json.encode(Data)
		
		local x, y = Entity:GetPosition()
		Datagram = Datagram
			:WriteInt24(Connection.EntityQueueSize)
			:WriteInt24(Entity.ID)
			:WriteLine(Entity.Class)
			:WriteInt(x)
			:WriteInt(y)
			:WriteShort(Entity:GetAngle() + 360)
			:WriteInt24(#Data)
			:WriteString(Encoded)
		
		Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
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