local Transfer = Core.Transfer
local State = Core.State

function Transfer.Update()
	for Address, Connection in pairs(State.PlayersConnecting) do
		if Connection.Stage == CONST.NET.STAGE.GETFILELIST then
			for _, File in pairs(Core.State.Transfer) do
				table.insert(Player.Transfer, {Path = File})
			end
			
			Connection.Stage = CONST.NET.STAGE.CONNECTING
		elseif Connection.Stage == CONST.NET.STAGE.CONNECTING then
			local GeneratingInfo
			for Index, File in pairs(Connection.Transfer) do
				if not File.Checksum then
					-- Generate file info
					if File.Path:sub(1, 4) == "src/" then
						File.Size = 0
						File.Handle = love.filesystem.newFile(File.Path, "r")
					else
						File.Size = lfs.attributes(File.Path, "size")
						File.Handle = io.open(File.Path, "rb")
					end
					
					local Content = ""
					while not File.Handle:eof() do
						Content = Content .. File.Handle:read("*a")
					end
					File.Checksum = md5.checksum(Content)
					
					if File.Handle then
						GeneratingInfo = true
						break
					else
						Connection.Transfer[Index] = nil
					end
				end
			end
			
			if not GeneratingInfo then
				local Datagram = ("")
					:WriteShort(CONST.NET.SERVERTRANSFER)
					:WriteByte(CONST.NET.STAGE.CONNECTING)
					
				for Index, File in pairs(Connection.Transfer) do
					Transfer = Transfer
						:WriteLine(File.Path)
						:WriteInt(File.Size)
						:WriteLine(File.Checksum)	-- MD5 hash
				end
				
				Connection.Stage = CONST.NET.STAGE.CHECKFILES
				Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
			end
			
		elseif Connection.Stage == CONST.NET.STAGE.GETFILENAME then
			
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
				Connection.EntityQueue = {}
				for ID, Entity in pairs(Core.State.Entities) do
					table.insert(Connection.EntityQueue, Entity)
				end
				Connection.EntityQueueSize = #Connection.EntityQueue
				
				Connection.Stage = CONST.NET.STAGE.GETSTATE
				Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
			end
			
		elseif Connection.Stage == CONST.NET.STAGE.GETFILE then
			
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
		
		elseif Connection.Stage == CONST.NET.STAGE.GETSTATE then
		
			local Datagram = ("")
				:WriteShort(CONST.NET.SERVERTRANSFER)
				:WriteByte(CONST.NET.STAGE.GETSTATE)
		
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
					:WriteShort(Entity:GetAngle())
					:WriteInt24(#Data)
					:WriteString(Encoded)
					
			else
				Datagram = Datagram
					:WriteInt24(0)
				
				Connection.Stage = CONST.NET.STAGE.AWAIT
			end
			
			Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
		end
	end
end