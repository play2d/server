local ClassMT = Core.LuaState.ClassMT
local Entity = {}

ClassMT.Entity = Entity

function lua.lua_pushentity(L, E)
	lua.lua_pushlightuserdata(L, E)
	lua.lua_getfield(L, lua.LUA_REGISTRYINDEX, "ent_"..E:GetClass())
	if lua.lua_istable(L, -1) then
		lua.lua_setmetatable(L, -2)
	end
end

function lua.lua_toentity(L, idx)
	if lua.lua_islightuserdata(L, 1) then
		local Pointer = lua.lua_touserdata(L, idx)
		if Pointer == nil then
			return nil
		end

		local Ent = ffi.cast("struct Entity *", Pointer)
		if Ent == nil then
			return nil
		end
		
		if Ent:IsValid() then
			return Ent
		end
	end
end

function Entity.GetName(L)
	local Ent = lua.lua_toentity(L, 1)
	
	if Ent then
		lua.lua_pushstring(L, Ent:GetName())
		return 1
	end
	
	return 0
end

function Entity.GetPosition(L)
	local Ent = lua.lua_toentity(L, 1)
	
	if Ent then
		local x, y = Ent:GetPosition()
		lua.lua_pushnumber(L, x)
		lua.lua_pushnumber(L, y)
		return 2
	end
	
	return 0
end

function Entity.Initialize(L)
	local Ent = lua.lua_toentity(L, 1)
	
	if Ent then
		Ent:Initialize()
	end
	
	return 0
end

function Entity.InitializePhysics(L)
	local Ent = lua.lua_toentity(L, 1)
	
	if Ent then
		Ent:InitializePhysics()
	end
	
	return 0
end

function Entity.CreateRectangleShape(L)
	
	return 0
end

function Entity.CreateCircleShape(L)
	
	return 0
end

function Entity.GetClass(L)
	local Ent = lua.lua_toentity(L, 1)

	if Ent then
		lua.lua_pushstring(L, Ent:GetClass())
		return 1
	end
	
	return 0
end