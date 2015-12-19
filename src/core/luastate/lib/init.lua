local State = Core.LuaState
local LuaState = Core.LuaState

LuaState.Function = {}
LuaState.ClassMT = {}

local Path = ...

require(Path..".core")
require(Path..".entities")
require(Path..".entity")