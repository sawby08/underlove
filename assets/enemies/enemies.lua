enemies = {}

enemies.one = {
    name = 'Poseur',
    x = 200,
    y = 138,
    image = love.graphics.newImage('assets/enemies/images/poseur.png'),
    xOff = 0,
    yOff = 0
}

enemies.two = {
    name = 'Posette',
    x = 440,
    y = 90,
    image = love.graphics.newImage('assets/enemies/images/posette.png'),
    xOff = 0,
    yOff = 0
}

enemies.stats = {amount = 2, canFlee = true}

enemies.encounter = {text = '* The potent posers pose[break]  proposterously!'}

function enemies:update(dt)

end

function enemies:draw()
    love.graphics.setColor(1, 1, 1)

    if enemies.stats.amount > 0 then
        love.graphics.draw(enemies.one.image, enemies.one.x - enemies.one.image:getWidth()/2, enemies.one.y - enemies.one.image:getHeight()/2)
    end
    if enemies.stats.amount > 1 then
        love.graphics.draw(enemies.two.image, enemies.two.x - enemies.two.image:getWidth()/2, enemies.two.y - enemies.two.image:getWidth()/2)
    end
end

return enemies