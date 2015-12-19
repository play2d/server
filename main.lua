game = {
	VERSION = "0.0.0.1a",
	CODENAME = "LuaJIT Rox",
	DATE = "13/07/2015",
}
SERVER = true

require("src.hook")
Hook.Create("update")

require("src.lib")
require("src.constants")
require("src.commands")
require("src.config")
require("src.core")
require("src.classes")

function love.load(arg)
	print("######################################################")
	print("Player2D Dedicated Server")
	--print("Game Version: "..game.VERSION.." "..game.CODENAME)
	print("Server Build for: "..game.VERSION.." "..game.CODENAME)
	print("System Time: "..os.date())
	print("Operating System: "..love.system.getOS())
	if jit then
		print(_VERSION.." / "..jit.version)
	else
		print(_VERSION)
	end
	print("######################################################")

	Commands.Load()
	Config.Load()
	Core.Load()

	print("######################################################")
	print("Server started")
end

function love.update(dt)
	Core.Update(dt)
	Hook.Call("update", dt)
end