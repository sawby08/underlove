Writer = {}

local text
local progString
local startX
local startY
local timeSince
local timeInterval
local color = 'white'
local animation = 'idle'
local updateI
local doingText
local isSleeping

Writer.isDone = nil

local textSounds = {}
textSounds[1] = love.audio.newSource('assets/sound/sfx/Voices/uifont.wav', 'static')

local colors = {
    white = {1, 1, 1},
    red = {1, 0, 0},
    green = {0, 1, 0},
    blue = {0, 0, 1},
    cyan = {0, 1, 1},
    yellow = {1, 1, 0},
    weirdRed = {1, .2, .4}
}

local function drawText(text, x, y, color, outlineColor)
    for i = -outlineWidth, outlineWidth do
        love.graphics.setColor(outlineColor)
        for j = -outlineWidth, outlineWidth do
            if i ~= 0 then
                love.graphics.print(text, x + i, y + j)
            end
        end
    end
    love.graphics.setColor(color)
    love.graphics.print(text, x, y)
end

function Writer:stop()
    doingText = false
    i = #text
    progString = ''
end

function Writer:setParams(string, x, y, font, time, sound)
    text = string or 'no string provided :/'
    progString = ""
    startX = x or 0
    startY = y or 0
    timeSince = 0
    timeInterval = time or 0.01
    textFont = font or fonts.default
    textSound = sound or 1
    i = 1
    doingText = true
    Writer.isDone = false
end

function Writer:update(dt)
    if doingText then
        timeSince = timeSince + dt
        local char = text:sub(i, i)
        if timeSince > timeInterval and #progString ~= #text and not input.secondary then
            if char ~= ' ' then
                textSounds[textSound]:stop()
                textSounds[textSound]:play()
            end
            if i <= #text then
                progString = text:sub(1, i)
                i = i + 1
                timeSince = 0
            end
        else
            if #progString == #text then
                Writer.isDone = true
            end
        end
        if char == '[' then
            local codeEnd = text:find("]", i)
            local code = text:sub(i + 1, codeEnd - 1)
            i = codeEnd + 1
        end
        if input.secondary then
            progString = text
            i = #text
            Writer.isDone = true
        end
    end
end


function Writer:draw()
    if doingText then
        love.graphics.setFont(textFont)
    
        local x = startX
        local y = startY
        local i = 1
        local animi = 1
        local shakeX = 0
        local shakeY = 0
        local letterShakeAmount = 0
    
        while i <= #text do
            local char = progString:sub(i, i)
            
            if char == '[' then
                local code = progString:match("%[%w+%]", i)
                if code then
                    code = code:sub(2, -2)
                    if code == 'break' then
                        x = startX
                        y = y + 32
                    elseif code == 'wave' then
                        animation = 'wave'
                    elseif code == 'shake' then
                        animation = 'shake'
                    elseif code == 'clear' then
                        animation = 'none'
                        color = 'white'
                    else
                        if colors[code] then
                            color = code
                        end
                    end
                    i = i + #code + 1
                end
            else
                if not animation ~= nil then
                    if animation == 'wave' then
                        shakeX = math.sin(love.timer.getTime() * -8 + animi) * 1.5
                        shakeY = math.cos(love.timer.getTime() * -8 + animi) * 1.5
                    elseif animation == 'shake' then
                        letterShakeAmount = 1
                        shakeX = love.math.random(-letterShakeAmount, letterShakeAmount)
                        shakeY = love.math.random(-letterShakeAmount, letterShakeAmount)
                    end
                end
                local currentColor = colors[color] or colors['white']
                love.graphics.setColor(currentColor)
    
                -- love.graphics.print(char, x + shakeX, y + shakeY)
                if animation ~= 'none' then
                    drawText(char, x + shakeX, y + shakeY, currentColor, {0, 0, 0})
                else
                    drawText(char, x, y, currentColor, {0, 0, 0})
                end

                x = x + love.graphics.getFont():getWidth(char)
            end
            i = i + 1
            if char ~= ' ' then
                animi = animi + 0.5
            end
        end
    end
end

return Writer