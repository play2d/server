local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.CONNECTING] = function (Connection)
	local GeneratingInfo
	for Index, File in pairs(Connection.Transfer) do
		if not File.Checksum then
			-- Generate file info
			if File.Path:sub(1, 4) == "src/" then
				File.Size = 0
				File.Handle = love.filesystem.newFile(File.Path, "r")
			else
				File.Size = lfs.attributes(File.Path, "size")
				File.Handle = io.open(File.Path, "rb")
			end
			
			local Content = ""
			while not File.Handle:eof() do
				Content = Content .. File.Handle:read("*a")
			end
			File.Checksum = md5.sumhexa(Content)
			
			if File.Handle then
				GeneratingInfo = true
				break
			else
				Connection.Transfer[Index] = nil
			end
		end
	end
	
	if not GeneratingInfo then
		local Datagram = ("")
			:WriteShort(CONST.NET.SERVERTRANSFER)
			:WriteByte(CONST.NET.STAGE.CONNECTING)
			
		for Index, File in pairs(Connection.Transfer) do
			Transfer = Transfer
				:WriteLine(File.Path)
				:WriteInt(File.Size)
				:WriteLine(File.Checksum)	-- MD5 hash
		end
		
		Connection.Stage = CONST.NET.STAGE.CHECKFILES
		Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
	end
end