if not SERVER then
	return nil
end

Config.CFG["sv_password"] = ""

local Command = {
	Category = "Server"
}

function Command.Call(Source, Password)
	if type(Password) == "string" then
		Config.CFG["sv_password"] = Password
	end
end

function Command.GetSaveString()
	return "sv_password " .. Config.CFG["sv_password"]
end

return Command