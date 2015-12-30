local State = Core.State
local LuaState = Core.LuaState

Hook.Create("StartRound")

function State.Load()
	print("Starting server...")
	if not State.Start then
		State.Renew()
	end
end

function State.Renew()
	-- This is pretty much a changemap
	
	local Datagram = ("")
		:WriteShort(CONST.NET.CHANGEMAP)
		:WriteLine(Config.CFG["sv_map"])
	
	Core.Network.ForEachConnection(
		function (ID, Connection)
			Connection.Peer:send(Datagram, CONST.NET.CHANNELS.MAP, "reliable")
			Connection.Peer:disconnect_later()
			Core.Network.RemoveConnection(Connection.Peer)
		end
	)
	
	if not State.Map then
		error("FAILED TO LOAD MAP")
	end
	
	State.Addons.List = State.Addons.Load()
	LuaState.Renew()
	
	State.Mode = "Play2D"
	State.Start = love.timer.getTime()
	
	State.ConVars = {}
	State.PlayersConnecting = {}		-- This should store an array of the connected peers of players connecting
	State.PlayersConnected = {}		-- This should store an array of the connected peers of the players
	State.Players = {}					-- This should store an array of entities
	State.Transfer = {State.Map.Path}
	State.Entities = {}
	State.EntitiesUQ = {}				-- Update Queue
	
	for _, Addon in pairs(State.Addons.List) do
		for _, Entity in pairs(Addon.Entities) do
			table.insert(State.Transfer, Entity)
		end
		for _, Autorun in pairs(Addon.Autorun.CL) do
			table.insert(State.Transfer, Autorun)
		end
		for _, Autorun in pairs(Addon.Autorun.SH) do
			table.insert(State.Transfer, Autorun)
		end
	end
	
	LuaState.Load()
	State.Map:GenerateWorld()
	State.Map:GenerateEntities()
	
	Hook.Call("StartRound")
end

function State.Reset()
	-- This is a map restart, it removes stuff
	
	State.Entities = {}
	State.EntitiesUQ = {}

	if State.Map then
		State.Map:GenerateWorld()
		State.Map:GenerateEntities()
	end
	
	local Datagram = ("")
		:WriteShort(CONST.NET.RESTARTMAP)
	
	Core.Network.ForEachConnection(
		function (ID, Connection)
			Connection.Peer:send(Datagram, CONST.NET.CHANNELS.STATE, "reliable")
		end
	)
	
	Hook.Call("StartRound")
end

function State.Update(dt)
	local Entities = State.EntitiesUQ
	local CurrentTime = love.timer.getTime()
	
	for Time, Entity in pairs(Entities) do
		if CurrentTime <= Time then
			Entities[Time] = nil
			LuaState.State:pcall(Entity.Update, Entity)
		end
	end

	State.Map.World:update(dt)
end