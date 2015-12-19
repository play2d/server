if not SERVER then
	return nil
end

local Command = {}

function Command.Call(Source)
	State.Reset()
end

return Command