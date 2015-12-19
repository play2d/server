Core.Network.Protocol[CONST.NET.PLAYERCONNECT] = function (Peer, Message)
	local IP = tostring(Peer):match("(.+)%:")
	local Name, Message = Message:ReadLine()		-- Check name ban
	local Login, Message = Message:ReadLine()		-- Later, we'll check this login.
	local Version, Message = Message:ReadLine()
	local Password, Message = Message:ReadLine()
	local MicrophonePort, Message = Message:ReadShort()
	
	local Response = ("")
		:WriteShort(CONST.NET.PLAYERCONNECT)
	
	local Time = love.timer.getTime()
	
	print("Received join attempt from "..tostring(Peer)..": "..Name.." ("..Login..")")
	
	if Core.Bans.IsIPBanned(IP) then
		-- Check IP ban
		
		Response = Response
			:WriteByte(CONST.NET.CONMSG.IPBAN)
			:WriteInt((Core.Bans.IP[IP].End or Time) - Time)
			:WriteLine((Core.Bans.IP[IP].Reason or ""):gsub("\n", ""))
		
		print("Join attempt rejected, IP banned: "..IP)
		return Peer:send(Response, CONST.NET.UNCONNECTED, "reliable")
	elseif Core.Bans.IsNameBanned(Name) then
		-- Check name ban
		
		Response = Response
			:WriteByte(CONST.NET.CONMSG.NAMEBAN)
			:WriteInt((Core.Bans.Name[Name].End or Time) - Time)
			:WriteLine((Core.Bans.Name[Name].Reason or ""):gsub("\n", ""))
		
		print("Join attempt rejected, name banned: "..Name)
		return Peer:send(Response, CONST.NET.UNCONNECTED, "reliable")
	elseif Core.Bans.IsLoginBanned(Login) then
		-- Check login ban
		
		Response = Response
			:WriteByte(CONST.NET.CONMSG.LOGINBAN)
			:WriteInt((Core.Bans.Login[Login].End or Time) - Time)
			:WriteLine((Core.Bans.Login[Login].Reason or ""):gsub("\n", ""))
		
		print("Join attempt rejected, login banned: "..Login)
		return Peer:send(Response, CONST.NET.UNCONNECTED, "reliable")
	elseif Version ~= game.VERSION then
		-- Version differs
		
		Response = Response
			:WriteByte(CONST.NET.CONMSG.DIFVER)
			:WriteLine(game.VERSION)
		
		print("Join attempt rejected, different version: "..Version)
		return Peer:send(Response, CONST.NET.UNCONNECTED, "reliable")
	elseif Password ~= Config.CFG["sv_password"] then
		-- Wrong password
		
		Response = Response
			:WriteByte(CONST.NET.CONMSG.WRONGPASS)
			
		print("Join attempt rejected, wrong password: "..Password)
		return Peer:send(Response, CONST.NET.UNCONNECTED, "reliable")
	end
	
	if table.count(Core.State.PlayersConnecting) + table.count(Core.State.PlayersConnected) >= Core.State.GetMaxPlayers() then
		-- Slot unavailable
		
		Response = Response
			:WriteByte(CONST.NET.CONMSG.SLOTUNAVAIL)
		
		print("Join attempt rejected, slot unavailable")
		return Peer:send(Response, CONST.NET.UNCONNECTED, "reliable")
	end
	
	-- Connection accepted
	Response = Response
		:WriteByte(CONST.NET.CONMSG.ACCEPTED)
		
	Peer:send(Response, CONST.NET.CHANNELS.CONNECTING, "reliable")
	
	local Player = {}
	Player.Peer = Peer
	Player.Transfer = {}
	Player.Stage = CONST.NET.STAGE.GETFILELIST
	
	Core.State.PlayersConnecting[tostring(Peer)] = Player
	print("Join attempt accepted")
end