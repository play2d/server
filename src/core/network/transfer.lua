Hook.Create("PlayerJoin")

Core.Network.Protocol[CONST.NET.SERVERTRANSFER] = function (Peer, Message)
	local Connection = Core.State.PlayersConnecting[tostring(Peer)]
	if Connection then
		
		local Byte, Message = Message:ReadByte()
		
		if Byte == CONST.NET.STAGE.CANCEL then
			-- Join process cancelled
			
			Core.State.PlayersConnecting[tostring(Peer)] = nil
			Peer:disconnect()
			
			if Connection.Transfer then
				for Index, File in pairs(Connection.Transfer) do
					if File.Handle then
						File.Handle:close()
					end
					Connection.Transfer[Index] = nil
				end
			end
			
		elseif Connection.Stage == CONST.NET.STAGE.CONNECTING then
			
			if Byte == CONST.NET.STAGE.CONNECTING then
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
					end
				end
				Connection.Stage = CONST.NET.STAGE.GETFILENAME
			end
			
		elseif Connection.Stage == CONST.NET.STAGE.CONFIRM then
			
			if Byte == CONST.NET.STAGE.CONFIRM then
				Connection.Stage = CONST.NET.STAGE.GETFILENAME
			end
			
		elseif Connection.Stage == CONST.NET.STAGE.AWAITING then
			
			if Byte == CONST.NET.STAGE.JOIN then
				-- This player finished downloading game state, make it join to the match
				
				Core.State.PlayersConnecting[tostring(Peer)] = nil
				Core.State.PlayersConnected[tostring(Peer)] = Connection
				
				Connection.Transfer = nil
				
				Hook.Call("PlayerJoin", tostring(Peer))
			end
			
		end
	
	end
end