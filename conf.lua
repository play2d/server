function love.conf(t)
	t.identity = "play2d dedicated server"
	t.version = "0.9.2"
	t.console = true
	
	t.window = false
	t.modules.audio = true
	t.modules.event = false
	t.modules.graphics = false
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = false
	t.modules.math = true
	t.modules.mouse = false
	t.modules.physics = true
	t.modules.sound = true
	t.modules.system = true
	t.modules.timer = true
	t.modules.window = false
	t.modules.thread = true
end

function love.run()
 
	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1, 3 do love.math.random() end
	end
 
	if love.event then
		love.event.pump()
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	while true do
		local start = love.timer.getTime()
		
		-- Process events.
		if love.event then
			love.event.pump()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						return
					end
				end
				love.handlers[e](a,b,c,d)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
		
		if love.timer then love.timer.sleep(0.01515 + start - love.timer.getTime()) end
	end
 
end

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end
 
function love.errhand(msg)
	msg = tostring(msg)
	error_printer(msg, 2)
	print("Activating sleep mode, 99999 seconds left")
	socket.sleep(99999)
end