if not SERVER then
	return nil
end

local Command = {}

function Command.Call(Source, IP, Reason, Duration)
	if type(IP) ~= "string" then
		return nil
	end
	if type(Reason) ~= "string" then
		Reason = nil
	end
	if type(Duration) ~= "number" then
		Duration = nil
	end
	Bans.CreateIP(IP, Duration, Reason)
end

return Command