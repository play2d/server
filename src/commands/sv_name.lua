if not SERVER then
	return nil
end

Config.CFG["sv_name"] = "Server"

local Command = {
	Category = "Server"
}

function Command.Call(Source, Name)
	if type(Name) == "string" then
		Config.CFG["sv_name"] = Name
	end
end

function Command.GetSaveString()
	return "sv_name " .. Config.CFG["sv_name"]
end

return Command