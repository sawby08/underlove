Ui = {}

local buttonNames = {'fight', 'act', 'item', 'mercy'}
local buttonImages = {}
local buttonQuads = {}

for _, name in ipairs(buttonNames) do
    buttonImages[name .. 'bt'] = love.graphics.newImage('assets/images/ui/bt/' .. name .. '.png')
    buttonQuads[name .. 'Quads'] = {
        love.graphics.newQuad(0, 0, 110, 42, buttonImages[name .. 'bt']),
        love.graphics.newQuad(110, 0, 110, 42, buttonImages[name .. 'bt'])
    }
end

local ref = love.graphics.newImage('assets/images/refs/main.png')

local hpname = love.graphics.newImage("assets/images/ui/spr_hpname_0.png")
local krGraphic = love.graphics.newImage("assets/images/ui/spr_krmeter_0.png")

local arenaCur = {
    x = 320,
    y = 320,
    width = 570,
    height = 135,
    rotation = 0
}

local targetChoiceX = 0
local direction = nil
local targetChoiceAnim = false
local moving = true
local speed = 12

local fightUi = {
    target = love.graphics.newImage('assets/images/ui/spr_target_0.png'),
    targetChoice = {}
}

fightUi.targetChoice = {
    love.graphics.newImage('assets/images/ui/spr_targetchoice_0.png'),
    love.graphics.newImage('assets/images/ui/spr_targetchoice_1.png')
}

local function setHeartParams()
    maxLeft = math.floor(arenaCur.x - (arenaCur.width / 2) + 6)
    maxUp = math.floor(arenaCur.y - (arenaCur.height / 2) + 6)
    maxDown = math.floor(arenaCur.y + (arenaCur.height / 2) - 21)
    maxRight = math.floor(arenaCur.x + (arenaCur.width / 2) - 21)
end

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

local function drawGraphic(image, x, y, color, outlineColor)
    for i = -outlineWidth, outlineWidth do
        love.graphics.setColor(outlineColor)
        for j = -outlineWidth, outlineWidth do
            if i ~= 0 then
                love.graphics.draw(image, x + i, y + j)
            end
        end
    end
    love.graphics.setColor(color)
    love.graphics.draw(image, x, y)
end

local function drawQuad(image, quad, x, y, color, outlineColor)
    for i = -outlineWidth, outlineWidth do
        love.graphics.setColor(outlineColor)
        for j = -outlineWidth, outlineWidth do
            if i ~= 0 then
                love.graphics.draw(image, quad, x + i, y + j)
            end
        end
    end
    love.graphics.setColor(color)
    love.graphics.draw(image, quad, x, y)
end

local function buttons()
    local color
    local outlineClr

    local positions = {
        fight = 32,
        act = 185,
        item = 345,
        mercy = 500
    }
    
    for i, name in ipairs(buttonNames) do
        drawQuad(buttonImages[name .. 'bt'], buttonQuads[name .. 'Quads'][(global.choice == (i-1)) and 2 or 1], positions[name], 432, {1, 1, 1}, {0, 0, 0})
    end
end

local function stats()
    if Player.stats.hp > Player.stats.maxhp then
        Player.stats.hp = Player.stats.maxhp
    end

    love.graphics.setFont(fonts.mnc)
    drawText(Player.stats.name .. '   LV ' .. Player.stats.love, 30, 400, {1, 1, 1}, {0, 0, 0})

    drawGraphic(hpname, 240, 400, {1, 1, 1}, {0, 0, 0})
    if Player.stats.hasKR then drawGraphic(krGraphic, 395, 405, {1, 1, 1}, {0, 0, 0}) end

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', 275 - outlineWidth, 400 - outlineWidth, (Player.stats.maxhp * 1.2) + outlineWidth*2, 21 + outlineWidth*2)
    love.graphics.setColor(0.75, 0, 0, 1)
    love.graphics.rectangle('fill', 275, 400, (Player.stats.maxhp * 1.2), 21)
    love.graphics.setColor(0.98, 1, 0, 1)
    love.graphics.rectangle('fill', 275, 400, (Player.stats.hp * 1.2), 21)

    love.graphics.setColor(1, 1, 1)
    if Player.stats.hasKR then
        if (Player.stats.hp > -1 and Player.stats.hp < 10) then
            drawText("0" .. Player.stats.hp .. " / " .. Player.stats.maxhp, 320 + (Player.stats.maxhp * 1.2), 400, {1, 1, 1}, {0, 0, 0})
        else
            drawText(Player.stats.hp .. " / " .. Player.stats.maxhp, 320 + (Player.stats.maxhp * 1.2), 400, {1, 1, 1}, {0, 0, 0})
        end
    else
        if (Player.stats.hp > -1 and Player.stats.hp < 10) then
            drawText("0" .. Player.stats.hp .. " / " .. Player.stats.maxhp, 289 + (Player.stats.maxhp * 1.2), 400, {1, 1, 1}, {0, 0, 0})
        else
            drawText(Player.stats.hp .. " / " .. Player.stats.maxhp, 289 + (Player.stats.maxhp * 1.2), 400, {1, 1, 1}, {0, 0, 0})
        end
    end
end

local function arena()
    love.graphics.push()
    love.graphics.translate(arenaCur.x, arenaCur.y)
    love.graphics.rotate(math.rad(arenaCur.rotation))
    local verts = {
        -arenaCur.width / 2, arenaCur.height / 2,
        arenaCur.width / 2, arenaCur.height / 2,
        arenaCur.width / 2, -arenaCur.height / 2,
        -arenaCur.width / 2, -arenaCur.height / 2
    }
    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.setLineStyle('rough')
    love.graphics.setLineWidth(5)
    love.graphics.polygon('fill', verts)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineStyle('rough')
    love.graphics.setLineWidth(5 + outlineWidth*2)
    love.graphics.polygon('line', verts)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineStyle('rough')
    love.graphics.setLineWidth(5)
    love.graphics.polygon('line', verts)
    love.graphics.pop()
end

local function updateArena()
    arenaCur.x = arenaCur.x + ((Ui.arenaTo.x - arenaCur.x) / 6) * love.timer.getDelta() * 30
    arenaCur.y = arenaCur.y + ((Ui.arenaTo.y - arenaCur.y) / 6) * love.timer.getDelta() * 30
    arenaCur.width = arenaCur.width + ((Ui.arenaTo.width - arenaCur.width) / 6) * love.timer.getDelta() * 30
    arenaCur.height = arenaCur.height + ((Ui.arenaTo.height - arenaCur.height) / 6) * love.timer.getDelta() * 30
    arenaCur.rotation = arenaCur.rotation + ((Ui.arenaTo.rotation - arenaCur.rotation) / 6) * love.timer.getDelta() * 30
    setHeartParams()
end

local function doActText()
    love.graphics.setFont(fonts.determination)
    if Player.chosenEnemy == 0 then
        Player.actAmount = #enemies[1].acts
        local xOffset = 85
        local yOffset = 274
        local xSpacing = 215
        local ySpacing = 32
        
        for i = 1, #enemies[1].acts do
            local act = enemies[1].acts[i]
            local x = xOffset + ((i - 1) % 2) * xSpacing
            local y = yOffset + math.floor((i - 1) / 2) * ySpacing
            
            drawText('* ' .. act, x, y, {1, 1, 1}, {0, 0, 0})
        end
    end
    if Player.chosenEnemy == 1 then
        Player.actAmount = #enemies[2].acts
        local xOffset = 85
        local yOffset = 274
        local xSpacing = 215
        local ySpacing = 32
        
        for i = 1, #enemies[2].acts do
            local act = enemies[2].acts[i]
            local x = xOffset + ((i - 1) % 2) * xSpacing
            local y = yOffset + math.floor((i - 1) / 2) * ySpacing
            
            drawText('* ' .. act, x, y, {1, 1, 1}, {0, 0, 0})
        end
    end
    if Player.chosenEnemy == 2 then
        Player.actAmount = #enemies[3].acts
        local xOffset = 85
        local yOffset = 274
        local xSpacing = 215
        local ySpacing = 32
        
        for i = 1, #enemies[2].acts do
            local act = enemies[2].acts[i]
            local x = xOffset + ((i - 1) % 2) * xSpacing
            local y = yOffset + math.floor((i - 1) / 2) * ySpacing
            
            drawText('* ' .. act, x, y, {1, 1, 1}, {0, 0, 0})
        end
    end
end

local function doChooseText()
    love.graphics.setFont(fonts.determination)
    for i = 1, math.min(enemies.stats.amount, 3) do
        local enemy = enemies[i]
        local yPosition = 274 + (i - 1) * 32
        local txt = '* ' .. enemy.name

        local opacity
        if enemy.state == 'alive' then
            opacity = 1
        else
            opacity = .5
        end
    
        if enemy.canSpare then
            color = {1, 1, 0, opacity}
        else
            color = {1, 1, 1, opacity}
        end

        drawText(txt, 85, yPosition, color, {0, 0, 0})
    
        if opacity == 1 and enemies.encounter.showHPbar then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle('fill', 106 + (#txt * 16) - outlineWidth, yPosition+6 - outlineWidth, 125 + outlineWidth*2, 16 + outlineWidth*2)
            love.graphics.setColor(0.8, 0, 0)
            love.graphics.rectangle('fill', 106 + (#txt * 16), yPosition + 6, (enemy.maxhp / enemy.maxhp) * 125, 16)
            love.graphics.setColor(0, 0.8, 0)
            love.graphics.rectangle('fill', 106 + (#txt * 16), yPosition + 6, (enemy.hp / enemy.maxhp) * 125, 16)
        end
    end    
end

local function doMercyText()
    love.graphics.setFont(fonts.determination)

    local color
    color = {1, 1, 1}
    
    for i=1, math.min(enemies.stats.amount) do
        if enemies[i].canSpare then
            color = {1, 1, 0}
        end
    end
    
    drawText('* Spare', 85, 274, color, {0, 0, 0})
    if enemies.stats.canFlee then
        local color = {1, 1, 1}
        drawText('* Flee', 85, 306, color, {0, 0, 0})
    end
end

local function doItemText()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.determination)

    local offset = math.sin(love.timer.getTime()*4)
    
    if itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'type') == 'consumable' then
        drawText('* ' .. (itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'name') or 'None') .. ' (' .. (itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'stat') or 'None') .. ' HP)', 52, 274, {1, 1, 1}, {0, 0, 0})
    elseif itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'type') == 'weapon' then
        drawText('* ' .. (itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'name') or 'None') .. ' (' .. (itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'stat') or 'None') .. ' ATT)', 52, 274, {1, 1, 1}, {0, 0, 0})
    elseif itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'type') == 'armor' then
        drawText('* ' .. (itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'name') or 'None') .. ' (' .. (itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'stat') or 'None') .. ' DEF)', 52, 274, {1, 1, 1}, {0, 0, 0})
    elseif itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'type') == 'usable' then
        drawText('* ' .. (itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'name') or 'None'), 52, 274, {1, 1, 1}, {0, 0, 0})
    end

    drawText("* " .. (itemManager:getPropertyfromID(Player.inventory[global.subChoice + 1], 'description') or 'None'), 52, 302, {1, 1, 1}, {0, 0, 0})

    if global.subChoice == 0 then
        drawText('<', 448, 342, {1, 1, 1, .5}, {0, 0, 0, .5})
    else
        drawText('<', 448 - offset, 342, {1, 1, 1}, {0, 0, 0})
    end

    drawText(global.subChoice + 1 .. '/' .. #Player.inventory, 502, 342, {1, 1, 1}, {0, 0, 0})

    if global.subChoice == #Player.inventory - 1 then
        drawText('>', 556, 342, {1, 1, 1, .5}, {0, 0, 0, .5})
    else
        drawText('>', 556 + offset, 342, {1, 1, 1}, {0, 0, 0})
    end
end

local function doFightUi()
    drawGraphic(fightUi.target, 320 - (fightUi.target:getWidth()/2), 320 - (fightUi.target:getHeight()/2), {1, 1, 1}, {0, 0, 0})
    love.graphics.draw(fightUi.targetChoice[math.floor(targetChoiceFrame*speed)+1], targetChoiceX, 256)
end

local function updateFightUi(dt)
    speed = 15
    if targetChoiceAnim then
        targetChoiceFrame = targetChoiceFrame + love.timer.getDelta()
        if targetChoiceFrame >= 2/speed then
            targetChoiceFrame = 0
        end
    end

    if input.primary then
        moving = false
        startEnemyTurn()
    end

    if targetChoiceX > 586 or targetChoiceX < 30 then
        moving = false
        startEnemyTurn()
    end

    if moving then
        targetChoiceX = targetChoiceX + direction * 30 * dt
    end
end

function Ui:initFight()
    Writer:stop()
    targetChoiceX = 0
    direction = nil
    targetChoiceAnim = false
    moving = true
    if love.math.random(0, 1) == 0 then
        targetChoiceX = 586
        direction = -13
    else
        targetChoiceX = 30
        direction = 13
    end
end

function Ui:draw()
    if global.battleState ~= "gameOver" then
        buttons()
        stats()
        arena()
        --love.graphics.setColor(1, 1, 1, .5)
        --love.graphics.draw(ref)
        if global.battleState == 'chooseEnemy' then
            doChooseText()
        elseif global.battleState == 'fight' then
            doFightUi()
        elseif global.battleState == 'act' then
            doActText()
        elseif global.battleState == 'item' then
            doItemText()
        elseif global.battleState == 'mercy' then
            doMercyText()
        end
    else
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.clear()
        love.graphics.setBackgroundColor(0, 0, 0, 1)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fonts.determination)
        drawText('GAME OVER', 320 - fonts.determination:getWidth('GAME OVER')/2, 240 - fonts.determination:getHeight('GAME OVER')/2, {1, 1, 1}, {0, 0, 0})
        drawText('womp womp', 320 - fonts.determination:getWidth('GAME OVER')/2, 240 - fonts.determination:getHeight('womp womp')/1.5, {1, 1, 1}, {0, 0, 0})
        drawText('game closes in maybe '..20-time.."secs", 320 - fonts.determination:getWidth('game closes in maybe 20 secs')/2, 240 - fonts.determination:getHeight('game closes in maybe 20 secs')/1.25, {1, 1, 1}, {0, 0, 0})
    end
end

function Ui:update(dt)
    updateArena()
    if player.stats.hp <= 0 then
        global.battleState = 'gameOver'
    end
    if global.battleState == 'fight' then
        updateFightUi(dt)
    end
end

return Ui