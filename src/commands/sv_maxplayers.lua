if not SERVER then
	return nil
end

Config.CFG["sv_maxplayers"] = 255

local Command = {
	Category = "Server"
}

function Command.Call(Source, MaxPlayers)
	if type(Name) == "number" then
		Config.CFG["sv_maxplayers"] = math.min(math.max(MaxPlayers, 0), 255)
	end
end

function Command.GetSaveString()
	return "sv_maxplayers " .. Config.CFG["sv_maxplayers"]
end

return Command