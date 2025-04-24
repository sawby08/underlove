local utf8 = require("utf8")

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end

	if love.audio then
		love.audio.stop()
		local err = love.audio.newSource('assets/sound/error oh no.mp3', 'stream')
        err:setLooping(true)
		love.audio.play(err)
	end

	love.graphics.reset()

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	i = 0

	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
		love.graphics.clear(0, 0, 0)

        love.graphics.setColor(1, 1, 0)
		love.graphics.setFont(fonts.determination)
		love.graphics.print('O', 5 + math.sin(love.timer.getTime() * -8 + 0) * 1.5, 5 + math.cos(love.timer.getTime() * -8 + 0) * 1.5)
        love.graphics.print('o', 21 + math.sin(love.timer.getTime() * -8 + 1) * 1.5, 5 + math.cos(love.timer.getTime() * -8 + 1) * 1.5)
        love.graphics.print('p', 37 + math.sin(love.timer.getTime() * -8 + 2) * 1.5, 5 + math.cos(love.timer.getTime() * -8 + 2) * 1.5)
        love.graphics.print('s', 53 + math.sin(love.timer.getTime() * -8 + 3) * 1.5, 5 + math.cos(love.timer.getTime() * -8 + 3) * 1.5)
        love.graphics.print('!', 69 + math.sin(love.timer.getTime() * -8 + 4) * 1.5, 5 + math.cos(love.timer.getTime() * -8 + 4) * 1.5)

		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(fonts.dotumche)
		love.graphics.printf(p, 5, 45, 640)

		love.graphics.setColor(1, 1, 0)
		love.graphics.print(control, 5, 300)

		i = i + love.timer.getDelta()

        enemies[1].image:setFilter('nearest', 'nearest')
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(enemies[1].image, 500, 340, math.sin(i) / 5, 1, 1, enemies[1].image:getWidth()/2, enemies[1].image:getHeight()/2)

		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		control = control .. "\nCopied to clipboard!"
	end

	control = ''
	if love.system then
		control = control .. "\n\nPress CTRL+C or tap to copy this error\nPress CTRL+R to restart the game\nPress ESC to close the game"
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "keypressed" and a == "r" and love.keyboard.isDown("lctrl", "rctrl") then
				return 'restart'
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()
	end
end