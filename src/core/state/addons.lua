Core.State.Addons = {}

local Addons = Core.State.Addons

function Addons.Load()
	local AddonList = {}
	
	for Folder in lfs.dir("addons") do
		local Addon = {
			Path = "addons/"..Folder,
		}
		
		if lfs.attributes(Addon.Path, "mode") == "directory" then
			Addon.Info = {}
			Addon.Entities = {}
			Addon.Autorun = {
				SV = {},
				CL = {},
				SH = {},
			}
			Addon.Maps = {
			}
			
			-- Addon Info (info.txt)
			local InfoFile = io.open(Addon.Path.."/info.txt", "r")
			if InfoFile then
				local InfoContent = InfoFile:read("*a")
				if #InfoContent > 0 then
					Addon.Info = json.decode(InfoContent)
				end
				InfoFile:close()
			end
			
			-- Lua Scripts
			local LuaPath = Addon.Path.."/lua"
			if lfs.attributes(LuaPath, "mode") == "directory" then
				
				-- Autorun
				local AutorunPath = LuaPath.."/autorun"
				if lfs.attributes(AutorunPath, "mode") == "directory" then

					for File in lfs.dir(AutorunPath) do
						if File:sub(1, 3) == "sv_" then
							table.insert(Addon.Autorun.SV, AutorunPath.."/"..File)
						elseif File:sub(1, 3) == "sh_" then
							table.insert(Addon.Autorun.SH, AutorunPath.."/"..File)
						elseif File:sub(1, 3) == "cl_" then
							table.insert(Addon.Autorun.CL, AutorunPath.."/"..File)
						end
					end
				end
				
				-- Entities
				local EntitiesPath = LuaPath.."/entities"
				if lfs.attributes(EntitiesPath, "mode") == "directory" then
					
					for File in lfs.dir(EntitiesPath) do
						table.insert(Addon.Entities, EntitiesPath.."/"..File)
					end
				end
			end
			
			-- Maps
			local MapsPath = Addon.Path.."/maps"
			if lfs.attributes(MapsPath, "mode") == "directory" then
				
				for File in lfs.dir(MapsPath) do
					table.insert(Addon.Maps, MapsPath.."/"..File)
				end
			end
			
			table.insert(AddonList, Addon)
		end
	end
	
	return AddonList
end

function Addons.LoadMaps()
	local MapList = {}
	
	for Folder in lfs.dir("addons") do
		local AddonPath = "addons/"..Folder
		if lfs.attributes(AddonPath, "mode") == "directory" then
			
			local MapsPath = AddonPath.."/maps"
			if lfs.attributes(MapsPath, "mode") == "directory" then
				
				for File in lfs.dir(MapsPath) do
					table.insert(MapList, MapsPath.."/"..File)
				end
			end
		end
	end
	
	return MapList
end