local Bans = Core.Bans

Bans.Login = {}
Bans.IP = {}
Bans.Name = {}

Hook.Create("Ban")
Hook.Create("Unban")

function Bans.IsLoginBanned(Login)
	return type(Bans.Login[Login]) == "table"
end

function Bans.IsIPBanned(IP)
	return type(Bans.IP[IP]) == "table"
end

function Bans.IsNameBanned(Name)
	return type(Bans.Name[Name]) == "table"
end

function Bans.CreateIP(IP, Duration, Reason)
	local Ban = {}
	if type(Duration) == "number" then
		Ban.End = love.timer.getTime() + Duration
	end
	if type(Reason) == "string" then
		Ban.Reason = Reason
	end
	Bans.IP[IP] = Ban
	Bans.Save()
	
	Hook.Call("Ban", IP, nil, nil, Duration, Reason)
end

function Bans.CreateName(Name, Duration, Reason)
	local Ban = {}
	if type(Duration) == "number" then
		Ban.End = love.timer.getTime() + Duration
	end
	if type(Reason) == "string" then
		Ban.Reason = Reason
	end
	Bans.Name[Name] = Ban
	Bans.Save()
	
	Hook.Call("Ban", nil, Name, nil, Duration, Reason)
end

function Bans.CreateLogin(Login, Duration, Reason)
	local Ban = {}
	if type(Duration) == "number" then
		Ban.End = love.timer.getTime() + Duration
	end
	if type(Reason) == "string" then
		Ban.Reason = Reason
	end
	Bans.Login[Login] = Ban
	Bans.Save()
	
	Hook.Call("Ban", nil, nil, Login, Duration, Reason)
end

function Bans.RemoveIP(IP)
	if Bans.IP[IP] then
		Bans.IP[IP] = nil
		
		Hook.Call("Unban", IP)
	end
end

function Bans.RemoveName(Name)
	if Bans.Name[Name] then
		Bans.Name[Name] = nil
		
		Hook.Call("Unban", nil, Name)
	end
end

function Bans.RemoveLogin(Login)
	if Bans.Login[Login] then
		Bans.Login[Login] = nil
		
		Hook.Call("Unban", nil, nil, Login)
	end
end

function Bans.Load()
	local File = io.open("sys/bans.lst", "r")
	if File then
		-- Load bans
		local Content = File:read("*a")
		if #Content > 0 then
			local Data = json.decode(Content)
			if Data then
				Bans.Login = Data.Login
				Bans.IP = Data.IP
				Bans.Name = Data.Name
			end
		end
		
		File:close()
	end
end

function Bans.Save()
	local File = io.open("sys/bans.lst", "w")
	if File then
		-- Save bans
		local Content = json.encode {Login = Bans.Login, IP = Bans.IP, Name = Bans.Name}
		if Content then
			File:write(Content)
		end
		
		File:close()
	end
end