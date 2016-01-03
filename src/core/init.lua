local Path = ...

Core = {}
Core.State = {}
Core.LuaState = {}
Core.Network = {}
Core.Transfer = {}
Core.Maps = {}
Core.Bans = {}

Hook.Create("StartRound")

-- Network hooks
Hook.Create("ENetConnect")
Hook.Create("ENetDisconnect")

-- Player hooks
Hook.Create("PlayerLeave")
Hook.Create("PlayerJoin")

require(Path..".state")
require(Path..".luastate")
require(Path..".network")
require(Path..".transfer")
require(Path..".map")
require(Path..".bans")

function Core.Load()
	Core.Network.Load()
	Core.State.Load()

	Core.Load = nil
end

function Core.Update(dt)
	Core.Transfer.Update(dt)
	Core.Network.Update(dt)
	Core.State.Update(dt)
end