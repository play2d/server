local State = Core.State

Core.Network.Protocol[CONST.NET.SERVERINFO] = function (Peer)
	local Response = ("")
		:WriteShort(CONST.NET.SERVERINFO)
		:WriteLine(game.VERSION)																						-- Game version
		:WriteLine(Config.CFG["sv_name"])																			-- Server name
		:WriteLine(Config.CFG["sv_map"])																				-- Map name
		:WriteLine(State.Mode or "")																					-- Game mode
		:WriteLine(Config.CFG["sv_website"])																		-- Website (optional), this is for communities
		:WriteByte(#Config.CFG["sv_password"] > 0 and 1 or 0)													-- Password protected
		:WriteByte(State.GetPlayersConnected())																	-- Amount of players
		:WriteByte(State.GetMaxPlayers())																			-- Maximum players
	Peer:send(Response, CONST.NET.CHANNELS.UNCONNECTED, "unsequenced")
end