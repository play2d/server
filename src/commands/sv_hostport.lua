if not SERVER then
	return nil
end

Config.CFG["sv_hostport"] = 0

local Command = {
	Category = "Server"
}

function Command.Call(Source, HostPort)
	if type(HostPort) == "number" then
		Config.CFG["sv_hostport"] = HostPort
	end
end

function Command.GetSaveString()
	return "sv_hostport " .. Config.CFG["sv_hostport"]
end

return Command