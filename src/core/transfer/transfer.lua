local Transfer = Core.Transfer
local State = Core.State

Transfer.Stage = {}

function Transfer.Update()
	for Address, Connection in pairs(State.PlayersConnecting) do
		local Function = Transfer.Stage[Connection.Stage]
		if Function then
			Function(Connection)
		end
	end
end