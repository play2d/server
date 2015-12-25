local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.GETFILELIST] = function (Connection)
	for _, File in pairs(Core.State.Transfer) do
		table.insert(Player.Transfer, {Path = File})
	end
	
	Connection.Stage = CONST.NET.STAGE.CONNECTING
end