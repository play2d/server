if not SERVER then
	return nil
end

local Command = {}

function Command.Call(Source, Name, Reason, Duration)
	if type(Name) ~= "string" then
		return nil
	end
	if type(Reason) ~= "string" then
		Reason = nil
	end
	if type(Duration) ~= "number" then
		Duration = nil
	end
	Bans.CreateName(Name, Duration, Reason)
end

return Command