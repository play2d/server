Core.Network.Protocol[CONST.NET.RCON] = function (Peer, Message)
	local RConPassword, Message = Message:ReadLine()
	local Command, Message = Message:ReadLine()
	
	if #RConPassword > 0 then
		if RConPassword == Config.CFG["sv_rcon"] then
			if #Command > 0 then
				parse(Command)
			end
		end
	end
end