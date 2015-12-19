local Format = {}
Format.Metatable = {__index = Format}

Core.Maps.Format.Base = Format

function Format:Load(Path, File)
end

if CLIENT then
	function Format:RenderFloor(MapX, MapY, ScreenX, ScreenY, ScreenWidth, ScreenHeight)
	end

	function Format:RenderTop(MapX, MapY, ScreenX, ScreenY, ScreenWidth, ScreenHeight)
	end
end

function Format:GenerateWorld()
end

function Format:GenerateEntities()
end

function Format:GetRandomSpawnPoint(Player)
end