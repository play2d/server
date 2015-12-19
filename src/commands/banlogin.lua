if not SERVER then
	return nil
end

local Command = {}

function Command.Call(Source, Login, Reason, Duration)
	if type(Login) ~= "string" then
		return nil
	end
	if type(Reason) ~= "string" then
		Reason = nil
	end
	if type(Duration) ~= "number" then
		Duration = nil
	end
	Bans.CreateLogin(Login, Duration, Reason)
end

return Command