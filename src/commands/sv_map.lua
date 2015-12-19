if not SERVER then
	return nil
end

local State = Core.State

Config.CFG["sv_map"] = ""

local Command = {
	Category = "Map"
}

function Command.Call(Source, Name)
	if type(Name) == "string" then
		if Name ~= Config.CFG["sv_map"] then
			Config.CFG["sv_map"] = Name
			
			local Maps = State.Addons.LoadMaps()
			for _, Path in pairs(Maps) do
				local File, Type = Path:match("([%w|%_]+)%.([%w|%_]+)")
				if File == Name then
					
					for Format, _ in pairs(Core.Maps.Format) do
						if Type:lower() == Format:lower() then
							State.Map = Core.Maps.Load(Path, Format)
							break
						end
					end
				end
			end
			
			State.Renew()
		end
	end
end

function Command.GetSaveString()
	return "sv_map " .. Config.CFG["sv_map"]
end

return Command