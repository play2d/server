Core.Network.Protocol = {}
Core.Network.Hosts = {}

local Path = ...
local Network = Core.Network
local State = Core.State

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

function Network.FindConnecting(Peer)
	local ID = Peer:connect_id()
	if ID then
		return State.PlayersConnecting[ID]
	end
end

function Network.FindConnected(Peer)
	local ID = Peer:connect_id()
	if ID then
		return State.PlayersConnected[ID]
	end
end

function Network.RemoveConnected(Peer)
	local ID = Peer:connect_id()
	if ID then
		State.PlayersConnected[ID] = nil
	end
end

function Network.RemoveConnecting(Peer)
	local ID = Peer:connect_id()
	if ID then
		local Connection = State.PlayersConnecting[ID]
		if Connection then
			if Connection.Transfer then
				for Index, File in pairs(Connection.Transfer) do
					if File.Handle then
						File.Handle:close()
					end
					Connection.Transfer[Index] = nil
				end
			end
			State.PlayersConnecting[ID] = nil
		end
	end
end

function Network.RemoveConnection(Peer)
	local ID = Peer:connect_id()
	if ID then
		State.PlayersConnected[ID] = nil
		
		local Connection = State.PlayersConnecting[ID]
		if Connection then
			if Connection.Transfer then
				for Index, File in pairs(Connection.Transfer) do
					if File.Handle then
						File.Handle:close()
					end
					Connection.Transfer[Index] = nil
				end
			end
			State.PlayersConnecting[ID] = nil
		end
	end
end

function Network.AddConnected(Peer, Connection)
	local ID = Peer:connect_id()
	if ID then
		State.PlayersConnecting[ID] = Connection
	end
	return ID
end

function Network.AddConnecting(Peer, Connection)
	local ID = Peer:connect_id()
	if ID then
		State.PlayersConnecting[ID] = Connection
	end
	return ID
end

function Network.SendPlayers(Datagram, Channel, Flags)
	for ID, Connection in pairs(State.PlayersConnected) do
		Connection.Peer:send(Datagram, Channel, Flags)
	end
	
	for ID, Connection in pairs(State.PlayersConnecting) do
		if Connection.Sync then
			Connection.Peer:send(Datagram, Channel, Flags)
		end
	end
end

function Network.ForEachConnection(Function)
	if State.PlayersConnected then
		table.foreach(State.PlayersConnected, Function)
	end
	if State.PlayersConnecting then
		table.foreach(State.PlayersConnecting, Function)
	end
end