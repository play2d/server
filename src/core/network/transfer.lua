Hook.Create("PlayerJoin")

Core.Network.Protocol[CONST.NET.SERVERTRANSFER] = function (Peer, Message)
	local Connection = Core.Network.FindConnecting(Peer)
	if Connection then
		local Byte, Message = Message:ReadByte()
		
		if Byte == CONST.NET.STAGE.CANCEL then
			-- Join process cancelled
			
			Core.Network.RemoveConnection(Peer)
			Peer:disconnect()
			
			if Connection.Transfer then
				for Index, File in pairs(Connection.Transfer) do
					if File.Handle then
						File.Handle:close()
					end
					Connection.Transfer[Index] = nil
				end
			end
			
		elseif Byte == CONST.NET.STAGE.CONNECTING then
			-- The list of files that the client requires
			local Transfer = {}
			
			while #Message > 0 do
				local Path
				Path, Message = Message:ReadLine()
				
				for _, File in pairs(Connection.Transfer) do
					if File.Path == Path then
						File.Required = true
						break
					end
				end
			end
				
			for Index, File in pairs(Connection.Transfer) do
				if not File.Required then
					File.Handle:close()
					Connection.Transfer[Index] = nil
				else
					File.Required = nil
				end
			end
			
			Connection.Stage = CONST.NET.STAGE.GETFILENAME
		elseif Connection.Stage == CONST.NET.STAGE.CONFIRM then
			
			if Byte == CONST.NET.STAGE.CONFIRM then
				Connection.Stage = CONST.NET.STAGE.GETFILENAME
			end
			
		elseif Connection.Stage == CONST.NET.STAGE.JOIN then
			
			if Byte == CONST.NET.STAGE.JOIN then
				-- This player finished downloading game state, make it join to the match
				
				Connection.Transfer = nil
				Connection.Sync = nil
				
				local Datagram = ("")
					:WriteShort(CONST.NET.PLAYERJOIN)
					:WriteInt(Connection.ID)
					:WriteLine(Connection.Name)
					
				Core.Network.SendPlayers(Datagram, CONST.NET.CHANNELS.PLAYERS, "reliable")
				
				Connection.Score = 0
				Connection.Kills = 0
				Connection.Deaths = 0

				Core.Network.RemoveConnecting(Peer)
				Core.Network.AddConnected(Peer, Connection)
				
				Hook.Call("PlayerJoin", Connection.ID)
			end
			
		end
	
	end
end