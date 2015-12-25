local Function = Core.LuaState.Function
local ConVar = {}

Function.ConVar = ConVar

function ConVar.Create(L)
	local Name = ffi.string(lua.luaL_checkstring(L, 1))
	
	if #Name > 0 then
		local CVar = Core.State.ConVars[Name]
		if not CVar then
			local CVar = ffi.new("struct ConVar")
			CVar.Name = Name
			CVar.Value = ""
			CVar.Save = false
			CVar.SendToClient = false
			
			Core.State.ConVars[Name] = CVar
		end
		
		lua.lua_pushcvar(L, CVar)
		return 1
	end
	
	return 0
end

function ConVar.Find(L)
	local Name = ffi.string(lua.luaL_checkstring(L, 1))
	
	if #Name > 0 then
		local CVar = Core.State.ConVars[Name]
		if CVar then
			lua.lua_pushcvar(L, CVar)
			return 1
		end
	end
	
	return 0
end

function ConVar.Delete(L)
	local Name = ffi.string(lua.luaL_checkstring(L, 1))
	
	if #Name > 0 then
		Core.State.ConVars[Name] = nil
	end
	
	return 0
end