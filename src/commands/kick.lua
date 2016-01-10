if not SERVER then
	return nil
end

local Command = {}

function Command.Call(Source, ID, Reason)
	if type(Name) ~= "string" then
		return nil
	end
	if type(ID) ~= "number" then
		return nil
	end
	Core.Bans.KickID(ID, Reason)
end

return Command