if not SERVER then
	return nil
end

Config.CFG["sv_website"] = ""

local Command = {
	Category = "Other"
}

function Command.Call(Source, Name)
	if type(Name) == "string" then
		Config.CFG["sv_website"] = Name
	end
end

function Command.GetSaveString()
	return "sv_website " .. Config.CFG["sv_website"]
end

return Command