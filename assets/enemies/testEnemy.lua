-- Define the Attack class
local Attack = {}
Attack.__index = Attack
-- Assuming a = {x = ..., y = ..., width = ..., height = ...}
-- Assuming b = {x = ..., y = ..., width = ..., height = ...}
time = 0
function isColliding(a,b)
    if ((b.x >= a.x + 16) or -- a.width
        (b.x + 16 <= a.x) or -- b.width
        (b.y >= a.y + 16) or -- a.height
        (b.y + 16 <= a.y)) then -- a.height
           return false 
    else return true
        end
 end
function Attack:new(image, x, y, updateFunc, dmg)
    if dmg ~= dmg or dmg == nil then
        dmg = 1
    end
    local attack = setmetatable({}, Attack)
    attack.image = image
    attack.x = x
    attack.y = y
    attack.dmg = dmg
    attack.update = function (self, dt) updateFunc(self,dt) end
    return attack
end

function Attack:draw()
--    local upperbound = Ui.arenaTo.y+Ui.arenaTo.height
--    local lowerbound = Ui.arenaTo.y
--    love.graphics.rectangle("line", Ui.arenaTo.x, Ui.arenaTo.y, Ui.arenaTo.width, Ui.arenaTo.height)
--    cr, cg, cb, ca = love.graphics.getColor()
--    love.graphics.setColor(1,0,0,1)
--    love.graphics.rectangle("line", Ui.arenaTo.x-(Ui.arenaTo.width/2), Ui.arenaTo.y-(Ui.arenaTo.height/2), Ui.arenaTo.width, Ui.arenaTo.height)
--    love.graphics.setColor(cr,cg,cb,ca)
    love.graphics.draw(self.image, self.x, self.y)
end

-- Modify the enemies table
enemies = {}

local color
local outlineWidth = 0

local bg = {}
bg[0] = love.graphics.newImage('assets/images/spr_battlebg_0.png')
bg[1] = love.graphics.newImage('assets/images/spr_battlebg_1.png')

function enemies:doAct()
    if Player.chosenEnemy == 0 then
        if enemies[1].acts[global.subChoice+1] == 'Check' then
            Writer:setParams("[clear]* POSEUR: ATT - 1 DEF - 1          [break]* Passionate poseur and wants[break]  more people to pose with.", 52, 274, fonts.determination, 0.02, 1)
        end
        if enemies[1].acts[global.subChoice+1] == 'Pose' then
            Writer:setParams("[clear]* You posed with Poseur.          [break]* It feels content with you, and[break]  is [yellow][wave]SPARING[clear] you now.", 52, 274, fonts.determination, 0.02, 1)
            enemies[1].canSpare = true
        end
        if enemies[1].acts[global.subChoice+1] == 'Kill' then
            Writer:setParams("[clear]* kill! your game crashes", 52, 274, fonts.determination, 0.02, 1)
        end
    elseif Player.chosenEnemy == 1 then
        if enemies[1].acts[global.subChoice+1] == 'Check' then
            Writer:setParams("[clear]* POSETTE: ATT - 5 DEF - 5          [break]* Poses with Poseur.          [break]* Nothing much more.", 52, 274, fonts.determination, 0.02, 1)
        end
        if enemies[1].acts[global.subChoice+1] == 'Pose' then
            Writer:setParams("[clear]* You posed with Posette.          [break]* It's impressed.", 52, 274, fonts.determination, 0.02, 1)
        end
    elseif Player.chosenEnemy == 2 then
        -- nothing here because there isn't a third enemy
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

function enemies:load()
    bgoffset = 0
    enemies[1] = {
        name = 'Poseur',
        x = 200,
        y = 137,
        image = love.graphics.newImage('assets/enemies/images/poseur.png'),
        xOff = 0,
        yOff = 0,
        def = 1,
        atk = 1,
        canSpare = false,
        state = 'alive',
        hp = 50,
        maxhp = 50,
        attacks = {
            Attack:new(love.graphics.newImage("assets/images/ut-heart-broken.png"), 200, 137, function(self, dt)
                -- Poseur-specific attack update logic here
  --              if isColliding(self, Player.heart) then
  --                  Player.stats.hp = Player.stats.hp - self.dmg
  --              end
  --              self.x = Player.heart.x+(24*dt)
  --              self.y = Player.heart.y+(24*dt)
            end)
        }
    }
    
    enemies[2] = {
        name = 'Posette',
        x = 440,
        y = 137,
        image = love.graphics.newImage('assets/enemies/images/posette.png'),
        xOff = 0,
        yOff = 0,
        def = 5,
        atk = 5,
        canSpare = false,
        state = 'alive',
        hp = 100,
        maxhp = 100,
        attacks = {
            Attack:new(love.graphics.newImage("assets/images/ut-heart-broken.png"), 0, -90, function(self, dt)
                -- Poseur-specific attack update logic here
                if isColliding(self, Player.heart) then
                    Player.stats.hp = Player.stats.hp - self.dmg
                end
                time = time + 1
                -- go down till the y is below 0, then select a random x position that is in the battle box and go back up
                if self.y < Ui.arenaTo.y-(Ui.arenaTo.height/2) then
                    self.y = Ui.arenaTo.y+(Ui.arenaTo.height/2)-16
                    self.x = math.random(Ui.arenaTo.x-(Ui.arenaTo.width/2), Ui.arenaTo.width+(Ui.arenaTo.x-(Ui.arenaTo.width/2)))
                else
                    self.y = self.y - (200)*dt
                end
        --       Ui.arenaTo.rotation = Ui.arenaTo.rotation + 1
                if time > 365 then -- turn lasts 365 frames (6 seconds and 5 frames)
                    time = 0
          --          Ui.arenaTo.rotation = 0
                    global.battleState = 'buttons'
                end
        --        self.x = Player.heart.x+(24*dt)
        --        self.y = Player.heart.y+(24*dt)
            end)
        }
    }
    
    enemies[1].acts = {'Check', 'Pose', 'Kill'}
    enemies[2].acts = {'Check', 'Pose'}
    
    enemies.stats = {amount = 2, canFlee = true}
    
    enemies.encounter = {
        text = '[clear]* The [red][shake]potent posers[clear] pose[break]  [cyan][wave]proposterously!',
        startFirst = false,
        showHPbar = true
    }

    enemies.bgm = love.audio.newSource('assets/enemies/bgm2.mp3', 'stream')
end

function enemies:update(dt)
    for i = 1, math.min(enemies.stats.amount, 3) do
        local enemy = enemies[i]
        if enemy.update then
            enemy:update(dt)
        end
        if global.battleState == 'enemyTurn' then
            for _, attack in ipairs(enemy.attacks) do
                attack:update(dt)
            end
        end
    end
end

function enemies:draw()
    for i = 1, math.min(enemies.stats.amount, 3) do
        local enemy = enemies[i]
        if enemy.state == 'alive' then
            color = {1, 1, 1}
        elseif enemy.state == 'spared' then
            color = {1, 1, 1, .5}
        elseif enemy.state == 'dead' then
            color = {1, 1, 1, .0}
        end
        drawGraphic(enemy.image, enemy.x - enemy.image:getWidth()/2 + enemy.xOff, enemy.y - enemy.image:getHeight()/2 + enemy.yOff, color, {0, 0, 0})
        if global.battleState == 'enemyTurn' then
            for _, attack in ipairs(enemy.attacks) do
                attack:draw()
            end
        end
    end
end

function enemies:background()
    love.graphics.setColor(0.15, 0, 0.3)
    love.graphics.rectangle('fill', 0, 0, 640, 480)
    love.graphics.setColor(1, 1, 1)
end

return enemies