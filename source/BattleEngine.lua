BattleEngine = {}

maxLeft, maxUp, maxDown, maxRight = 0, 0, 0, 0

playMusic = true

local particles = {dust = {}}
particles.dust[1] = love.graphics.newImage('assets/images/particles/spr_dustcloud_0.png')
particles.dust[2] = love.graphics.newImage('assets/images/particles/spr_dustcloud_1.png')
particles.dust[3] = love.graphics.newImage('assets/images/particles/spr_dustcloud_2.png')

function BattleEngine:load()
    Enemies:load()

    if enemies.encounter.startFirst then
        global.battleState = 'enemyTurn'
        global.choice = -1
    else
        global.battleState = 'buttons'
    end

    Ui = require('source.BattleEngine.ui')
    Writer = require('source.writer')

    if global.battleState == 'buttons' then gotoMenu() else -- go to menu
        startEnemyTurn()
    end

    Player = require('source.BattleEngine.player')
    Player:load()

    itemManager = require('source.BattleEngine.itemManager')
end

function BattleEngine:update(dt)
    if Player.stats.hp <= 0 then
        global.battleState = 'gameOver'
    end
    Ui:update(dt)
    Player:update(dt)
    Writer:update(dt)
    Enemies:update(dt)

    if playMusic then
        Enemies.bgm:setVolume(0.4)
        Enemies.bgm:setLooping(true)
        Enemies.bgm:play()
    end
end

function BattleEngine:draw()
    if global.battleState ~= 'gameOver' then
        Enemies:background()
        Enemies:draw()
    end
    Ui:draw()
    if global.battleState ~= 'gameOver' then
        Player:draw()
        Writer:draw()
    end
end


function gotoMenu()
    global.battleState = 'buttons'
    Ui.arenaTo = {
        x = 320,
        y = 320,
        width = 570,
        height = 135,
        rotation = 0
    }
    Writer:setParams(Enemies.encounter.text, 52, 274, fonts.determination, 0.02, 1)
end

function doFight()
    targetChoiceFrame = 0
end

function doFlee()
    Writer:setParams("[clear]* Don't waste my time.", 85, 306, fonts.determination, 0.02, 1)
end

function useItem()
    local ChosenItem = Player.inventory[global.subChoice + 1]

    if itemManager:getPropertyfromID(ChosenItem, 'type') == 'consumable' then
        if type(itemManager:getPropertyfromID(ChosenItem, 'stat')) == 'number' then
            Player.stats.hp = Player.stats.hp + itemManager:getPropertyfromID(ChosenItem, 'stat')
        elseif itemManager:getPropertyfromID(ChosenItem, 'stat') == 'All' then
            Player.stats.hp = Player.stats.maxhp
        end
        if Player.stats.hp >= Player.stats.maxhp then
            Writer:setParams("[clear]* You ate the " .. itemManager:getPropertyfromID(ChosenItem, 'name') .. '.     [break]* Your HP was maxed out!', 52, 274, fonts.determination, 0.02, 1)
        else
            Writer:setParams("[clear]* You ate the " .. itemManager:getPropertyfromID(ChosenItem, 'name') .. '.     [break]* You recovered ' .. itemManager:getPropertyfromID(ChosenItem, 'stat') .. ' HP.', 52, 274, fonts.determination, 0.02, 1)
        end
        table.remove(Player.inventory, global.subChoice + 1)
    elseif itemManager:getPropertyfromID(ChosenItem, 'type') == 'usable' then
  --      Writer:setParams("[clear]* You used the " .. itemManager:getPropertyfromID(ChosenItem, 'name') .. '.', 52, 274, fonts.determination, 0.02, 1)
        itemManager:getPropertyfromID(ChosenItem, 'onuse')(Player, Writer)
        --table.remove(Player.inventory, global.subChoice + 1)
    elseif itemManager:getPropertyfromID(ChosenItem, "type") == "armor" or itemManager:getPropertyfromID(ChosenItem, "type") == "weapon" then
        Writer:setParams("[clear]* You equipped the " .. itemManager:getPropertyfromID(ChosenItem, 'name') .. '.', 52, 274, fonts.determination, 0.02, 1)
    end
    if itemManager:getPropertyfromID(ChosenItem, 'type') == 'weapon' then
        local lastWeapon = Player.stats.weapon
        Player.stats.weapon = ChosenItem
        Player.inventory[global.subChoice + 1] = lastWeapon
    end

    if itemManager:getPropertyfromID(ChosenItem, 'type') == 'armor' then
        local lastArmor = Player.stats.armor
        Player.stats.armor = ChosenItem
        Player.inventory[global.subChoice + 1] = lastArmor
    end
end
function startEnemyTurn()
    global.battleState = 'enemyTurn'
    Ui.arenaTo = {x = 320, y = 320, width = 135, height = 135, rotation = 0}
    placeSoul()
end
    
return BattleEngine