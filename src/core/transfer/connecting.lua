local Transfer = Core.Transfer

Transfer.Stage[CONST.NET.STAGE.CONNECTING] = function (Connection)
	local GeneratingInfo
	for Index, File in pairs(Connection.Transfer) do
		if not File.Checksum then
			-- Generate file info
			if not File.Handle then
				if File.Path:sub(1, 4) == "src/" then
					File.Size = love.filesystem.getSize(File.Path) or 0
					File.Handle = love.filesystem.newFile(File.Path, "r")
				else
					File.Size = lfs.attributes(File.Path, "size")
					File.Handle = io.open(File.Path, "rb")
				end
				File.Content = ""
			end
			
			if File.Handle then
				File.Content = File.Content .. File.Handle:read("*a")
				if File.Handle:eof() then
					File.Checksum = md5.sumhexa(File.Content)
					File.Content = nil
					File.Handle:seek(0)
				end

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
			Datagram = Datagram
				:WriteLine(File.Path)
				:WriteInt(File.Size)
				:WriteLine(File.Checksum)	-- MD5 hash
		end
		
		Connection.Stage = CONST.NET.STAGE.CHECKFILES
		Connection.Peer:send(Datagram, CONST.NET.CHANNELS.CONNECTING, "reliable")
	end
end