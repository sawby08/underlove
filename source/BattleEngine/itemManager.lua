itemManager = {}

local itemNames = {
    'Monster Candy',
    'Stick',
    'Bandage',
    'Butterscotch Pie',
    'Tough Glove',
    'Faded Ribbon'
}

local itemStats = {
    10,
    1,
    10,
    'All',
    5,
    3
}

local itemDescs = {
    'Has a distinct, non-licorice\n  flavor.',
    'Its bark is worse than its\n  bite.',
    'It has already been used\n  several times.',
    'Butterscotch-cinnamon pie,\n  one slice.',
    'A worn pink leather glove. For\n  five-fingered folk.',
    "If you're cuter, monsters won't\n  hit you as hard."
}

local itemTypes = {
    'consumable',
    'weapon',
    'consumable',
    'consumable',
    'weapon',
    'armor'
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
    end
end

return itemManager