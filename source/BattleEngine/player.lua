Player = {}

local lastButton

local heart = {}

local sfx = {
    move = love.audio.newSource('assets/sound/sfx/menumove.wav', 'static'),
    select = love.audio.newSource('assets/sound/sfx/menuconfirm.wav', 'static'),
    heal = love.audio.newSource('assets/sound/sfx/snd_heal_c.wav', 'static'),
    err = love.audio.newSource('assets/sound/sfx/err.mp3', 'static')
}

local color
local lastButton
local xoff = 0
local yoff = 0

function placeSoul()
    heart.x = Ui.arenaTo.x - 8
    heart.y = Ui.arenaTo.y - 8
end

if global.battleState == 'enemyTalk' then
    heart.x = Ui.arenaTo.x - 8
    heart.y = Ui.arenaTo.y - 8
end

local function setDefAtk()
    if Player.stats.armor == 3 then -- if the current armor is bandage
        Player.stats.def = 1        -- set defense to 1
    else                            -- because bandage is a consumable, i have to write custom code for
        --                             the bandage to affect the player's defense
        Player.stats.def = itemManager:getPropertyfromID(Player.stats.armor, 'stat')
    end

    Player.stats.atk = itemManager:getPropertyfromID(Player.stats.weapon, 'stat')
end

local function buttonPos()
    heart.y = 446
    if global.choice == 0 then 
        heart.x = 40
    elseif global.choice == 1 then
        heart.x = 194
    elseif global.choice == 2 then
        heart.x = 353
    elseif global.choice == 3 then
        heart.x = 507
    end
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

function Player:load()
    Player.stats = {
        name = 'chara',
        love = 1,
        hp = 20,
        maxhp = 20,
        hasKR = false,
        armor = 3,
        weapon = 2,
        atk = 0,
        def = 0
    }
    heart = {
---@diagnostic disable-next-line: undefined-global
        image = love.graphics.newImage('assets/images/ut-heart.png'),
        x = Ui.arenaTo.x - 8,
        y = Ui.arenaTo.y - 8,
        gravity = 0,
        jumpstage = 3,
        jumptimer = 0,
        show = true
    }
    Player.mode = 'red'
    Player.inventory = {7, 4, 1, 1, 5, 6}
    Player.chosenEnemy = 0
    Player.actAmount = 0
end

function Player:update(dt)
    setDefAtk()
    if global.battleState == 'buttons' then
        if input.right then
            sfx.move:stop()
            sfx.move:play()
            global.choice = global.choice + 1
            if global.choice == 4 then
                global.choice = 0
            end
        elseif input.left then
            sfx.move:stop()
            sfx.move:play()
            global.choice = global.choice - 1
            if global.choice == -1 then
                global.choice = 3
            end
        elseif input.primary then
            if global.choice == 0 or global.choice == 1 then
                sfx.select:stop()
                sfx.select:play()
                Writer:stop()
                global.subChoice = 0
                global.battleState = 'chooseEnemy'
            elseif global.choice == 2 then
                if #Player.inventory > 0 then
                    sfx.select:stop()
                    sfx.select:play()
                    Writer:stop()
                    global.subChoice = 0
                    global.battleState = 'item'
                else
                    sfx.err:stop()
                    sfx.err:play()
                end
            elseif global.choice == 3 then
                sfx.select:stop()
                sfx.select:play()
                Writer:stop()
                global.subChoice = 0
                global.battleState = 'mercy'
            end
            input.primary = false
        end
        buttonPos()
    end
    if global.battleState == 'enemyTurn' then
        heart.show = true
        if Player.mode == 'red' then
            heart.x = heart.x + ((love.keyboard.isDown('right')and 1 or 0) - (love.keyboard.isDown('left')and 1 or 0)) * 4 / ((love.keyboard.isDown('x')and 1 or 0) + 1) * dt * 30
            heart.y = heart.y + ((love.keyboard.isDown('down')and 1 or 0) - (love.keyboard.isDown('up')and 1 or 0)) * 4 / ((love.keyboard.isDown('x')and 1 or 0) + 1) * dt * 30
        end
        if Player.mode == 'blue' then
            heart.x = heart.x + ((love.keyboard.isDown('right')and 1 or 0) - (love.keyboard.isDown('left')and 1 or 0)) * 4 / ((love.keyboard.isDown('x')and 1 or 0) + 1) * dt * 30

            if heart.y < maxDown then
                heart.gravity = heart.gravity + 0.75 * dt * 30
            end
        
            if heart.y >= maxDown then
                heart.gravity = 0
                heart.jumpstage = 1
                heart.jumptimer = 0
            end
        
            if love.keyboard.isDown('up') and heart.jumpstage == 1 then
                heart.jumpstage = 2
            end
        
            if love.keyboard.isDown('up') and heart.jumpstage == 2 and heart.jumptimer < 9 then
                heart.gravity = -6
                heart.jumptimer = heart.jumptimer + 1 * dt * 30
            end
        
            if not love.keyboard.isDown('up') and heart.jumpstage == 2 and heart.jumptimer < 8 then
                heart.jumpstage = 3
                heart.gravity = -1
            end
        
            heart.y = heart.y + heart.gravity * dt * 30
        end
        heart.x = math.max(maxLeft, math.min(heart.x, maxRight))
        heart.y = math.max(maxUp, math.min(heart.y, maxDown))
    end
    if global.battleState == 'chooseEnemy' then
        heart.x, heart.y = 55, 279+(global.subChoice*32)
        if input.up then
            if global.subChoice ~= 0 then
                sfx.move:stop()
                sfx.move:play()
                global.subChoice = global.subChoice - 1
            end
        end
        if input.down then
            if global.subChoice ~= enemies.stats.amount-1 then
                sfx.move:stop()
                sfx.move:play()
                global.subChoice = global.subChoice + 1
            end
        end
        if input.secondary then
            input.secondary = false
            buttonPos()
            gotoMenu()
        end
        if input.primary then
            input.primary = false
            if global.choice == 1 and enemies[global.subChoice + 1].state == 'alive' then
                Player.chosenEnemy = global.subChoice
                sfx.select:stop()
                sfx.select:play()
                global.subChoice = 0
                xoff = 0
                yoff = 0
                Writer:stop()
                global.battleState = 'act'
            elseif global.choice == 0 and enemies[global.subChoice + 1].state == 'alive' then
                global.battleState = 'fight'
                Ui:initFight()
                doFight()
                heart.show = false
                global.choice = -1
                sfx.select:stop()
                sfx.select:play()
            else
                sfx.err:stop()
                sfx.err:play()
            end
        end
    end
    if global.battleState == 'act' then
        heart.x, heart.y = 55+(xoff*215), 279+(yoff*32)
        local prevXoff, prevYoff = xoff, yoff

        local choices = {
            {0, 2, 4},
            {1, 3, 5}
        }

        global.subChoice = choices[xoff + 1][yoff + 1]

        if input.right and xoff == 0 then
            if (yoff == 0 and Player.actAmount > 1) or (yoff == 1 and Player.actAmount > 3) or (yoff == 2 and Player.actAmount > 5) then
                xoff = 1
            end
        elseif input.left and xoff == 1 then
            xoff = 0
        end

        if input.up and yoff > 0 then
            yoff = yoff - 1
        elseif input.down then
            local maxY = (xoff == 0 and {2, 4} or {4, 5})
            if (yoff < 2 and Player.actAmount > maxY[yoff + 1]) then
                yoff = yoff + 1
            end
        end

        
        if (prevXoff ~= xoff or prevYoff ~= yoff) then
            sfx.move:stop()
            sfx.move:play()
        end
        
        if input.secondary then
            global.subChoice = 0
            heart.x, heart.y = 55, 279+(global.subChoice*32)
            input.secondary = false
            global.battleState = 'chooseEnemy'
        end

        if input.primary then
            lastButton = global.choice
            global.battleState = 'doAct'
            global.choice = -1
            Enemies:doAct()
            heart.show = false
        end
    end
    if global.battleState == 'item' then
        heart.x, heart.y = 472, 348
        if input.secondary then
            input.secondary = false
            buttonPos()
            gotoMenu()
        elseif input.left then
            if global.subChoice ~= 0 then
                sfx.move:stop()
                sfx.move:play()
                global.subChoice = global.subChoice - 1
            else
                sfx.err:stop()
                sfx.err:play()
            end
        elseif input.right then
            if global.subChoice ~= #Player.inventory - 1 then
                sfx.move:stop()
                sfx.move:play()
                global.subChoice = global.subChoice + 1
            else
                sfx.err:stop()
                sfx.err:play()
            end
        elseif input.primary then
            lastButton = global.choice
            heart.show = false
            global.battleState = 'useItem'
            global.choice = -1
            sfx.heal:stop()
            sfx.heal:play()
            useItem()
        end
    end
    if global.battleState == 'mercy' then
        heart.x, heart.y = 55, 279+(global.subChoice*32)
        if input.up then
            if global.subChoice ~= 0 then
                sfx.move:stop()
                sfx.move:play()
                global.subChoice = global.subChoice - 1
            end
        end
        if input.down then
            if enemies.stats.canFlee and global.subChoice ~= 1 then
                sfx.move:stop()
                sfx.move:play()
                global.subChoice = global.subChoice + 1
            end
        end
        if input.secondary then
            input.secondary = false
            buttonPos()
            gotoMenu()
        end
        if input.primary then
            if global.subChoice == 0 then
                for i = 1, math.min(enemies.stats.amount, 3) do
                    local enemy = enemies[i]
                    if enemy.canSpare then
                        enemy.state = 'spared'
                        enemy.canSpare = false
                    end
                end
            elseif global.subChoice == 1 then
                playMusic = false
                Enemies.bgm:setLooping(false)
                Enemies.bgm:stop()
                global.choice = -1
                doFlee()
                global.battleState = 'flee'
            end
        end
    end
    if global.battleState == 'doAct' then
        if Writer.isDone and input.primary then
            if enemies[1].acts[global.subChoice+1] == 'Kill' then
                error('i told you')
            end
            global.choice = lastButton
            global.battleState = 'buttons'
            gotoMenu()
            buttonPos()
            heart.show = true
        end
    end
    if global.battleState == 'useItem' then
        if Writer.isDone and input.primary then
            global.choice = lastButton
            global.battleState = 'buttons'
            gotoMenu()
            buttonPos()
            heart.show = true
        end
    end
    if global.battleState == 'flee' then
        heart.x = heart.x - 3  * dt * 30
        if heart.x < 0 then
            reload()
        end
    end
    crashx = heart.x - 2
    crashy = heart.y
end

function Player:draw()
    if Player.mode == 'red' then
        color = {1, 0, 0}
    elseif Player.mode == 'blue' then
        color = {0, 0, 1}
    end
    if heart.show then
        drawGraphic(heart.image, heart.x, heart.y, color, {0, 0, 0})
    end
end

return Player