if not SERVER then
	return nil
end

Config.CFG["sv_rcon"] = ""

local Command = {
	Category = "Server"
}

function Command.Call(Source, Password)
	if type(Password) == "string" then
		Config.CFG["sv_rcon"] = Password
	end
end

function Command.GetSaveString()
	return "sv_rcon " .. Config.CFG["sv_rcon"]
end

return Command