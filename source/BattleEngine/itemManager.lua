itemManager = {}

local itemNames = {
    'Monster Candy',
    'Stick',
    'Bandage',
    'Butterscotch Pie',
    'Tough Glove',
    'Faded Ribbon',
    "Destroyed Notebook"
}

local itemStats = {
    10,
    1,
    10,
    'All',
    5,
    3,
    0
}

local itemDescs = {
    'Has a distinct, non-licorice\n  flavor.',
    'Its bark is worse than its\n  bite.',
    'It has already been used\n  several times.',
    'Butterscotch-cinnamon pie,\n  one slice.',
    'A worn pink leather glove. For\n  five-fingered folk.',
    "If you're cuter, monsters won't\n  hit you as hard.",
    "It seems abandoned. Just like\n this project."
}

local itemTypes = {
    'consumable',
    'weapon',
    'consumable',
    'consumable',
    'weapon',
    'armor',
    "usable"
}
local itemOnUse = {
    function(Player, text_drawerfunc)end,
    function(Player, text_drawerfunc)end,
    function(Player, text_drawerfunc)end,
    function(Player, text_drawerfunc)end,
    function(Player, text_drawerfunc)end,
    function(Player, text_drawerfunc)end,
    function(Player, TextWriter)
        TextWriter:setParams("[clear]* You used the " .. "Destroyed Notebook" .. '.     [break]* You recovered -' .. (Player.stats.hp/2) .. ' HP.', 52, 274, fonts.determination, 0.02, 1)
        Player.stats.hp = Player.stats.hp/2
    end,
}

function itemManager:getPropertyfromID(id, property)
    if property == 'name' then
        return itemNames[id]
    elseif property == 'stat' then
        return itemStats[id]
    elseif property == 'description' then
        return itemDescs[id]
    elseif property == 'type' then
        return itemTypes[id]
    elseif property == 'onuse' then
        return itemOnUse[id]
    end
end

return itemManager