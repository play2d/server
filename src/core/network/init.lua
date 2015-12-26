Core.Network.Protocol = {}
Core.Network.Hosts = {}

local Path = ...
local Network = Core.Network

-- Hooks
Hook.Create("ENetConnect")
Hook.Create("ENetDisconnect")

-- Master server messages
require(Path..".master_ping")

-- Server/Client messages
require(Path..".serverinfo")
require(Path..".connect")
require(Path..".transfer")
require(Path..".rcon")

function Network.CreateHost(Port)
	if type(Port) == "number" then
		local Host = enet.host_create("localhost:"..Port, 512, 0, CONST.NET.CHANNELS.MAX)
		if Host then
			print("UDP socket initialized using port "..Host:get_socket_address())
			table.insert(Network.Hosts, Host)
		else
			print("Failed to open socket", 255, 0, 0, 255)
		end
		return Host
	end
end

function Network.Load()
	Network.CreateHost(Config.CFG["sv_hostport"])
	Network.Load = nil
end

function Network.Update()
	if Network.Host then
		for _, Host in pairs(Network.Hosts) do
			local Event = Host:service(1)
			while Event do
				if Event.type == "receive" then
					local Message = Event.data
					local PacketType
					
					PacketType, Message = Message:ReadShort()
					local Function = Network.Protocol[PacketType]
					if Function then
						Function(Event.peer, Message)
					end
				elseif Event.type == "connect" then
					Hook.Call("ENetConnect", Event.peer)
				elseif Event.type == "disconnect" then
					Hook.Call("ENetDisconnect", Event.peer)
				end
				Event = Host:service()
			end
			Host:flush()
		end
	end
end


function Network.SendPlayers(Datagram, Channel, Flags)
	for Address, Connection in pairs(Core.State.PlayersConnected) do
		Connection.Peer:send(Datagram, Channel, Flags)
	end
	
	for Address, Connection in pairs(Core.State.PlayersConnecting) do
		if Connection.Sync then
			Connection.Peer:send(Datagram, Channel, Flags)
		end
	end
end