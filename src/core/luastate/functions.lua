local State = Core.LuaState
local LuaState = Core.LuaState

function LuaState.RegisterFunctions()
	for Name, F in pairs(LuaState.Function) do
		if type(F) == "function" then
			lua.lua_register(LuaState.State, Name, F)
		elseif type(F) == "table" then
			lua.lua_newtable(LuaState.State)
			for Name2, F2 in pairs(F) do
				lua.lua_pushcfunction(L, F2)
				lua.lua_setfield(L, -1, Name2)
				lua.lua_pop(L, 1)
			end
			lua.lua_setglobal(L, -1, Name)
			lua.lua_pop(L, 1)
		end
	end
end

function LuaState.RegisterMetatables()
	local L = LuaState.State

	for ClassName, Class in pairs(LuaState.ClassMT) do
		lua.lua_newtable(L)
		
		lua.lua_pushvalue(L, -1)
		lua.lua_setfield(L, -2, "__index")
		
		for Method, Value in pairs(Class) do
			if type(Value) == "function" then
				lua.lua_pushcfunction(L, Value)
				lua.lua_setfield(L, -2, Method)
			end
		end
		
		lua.lua_setfield(L, lua.LUA_REGISTRYINDEX, ClassName)
	end
end