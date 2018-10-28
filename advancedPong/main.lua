local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local deltaClock = 0
local enemyDeltaClock = 0
local enemyAttackClock = 0
local score = 0
local score2 = 0

local aliens = {}
local genAliens = {}
local alienBullets = {}

local controlling = false

local palletLocations = {pallet1 = {x = 16, y = screenHeight / 2 , w = 2, h = 2, rot = 0, health = 250}, pallet2 = {x = screenWidth - 18 - 16, y = screenHeight / 2, w = 2, h = 2, rot = 0, health = 250}}
local ballLocation = {x = screenWidth / 2, y = screenHeight / 2, r = 0}
local ballDir = {up = false, down = true, left = false, right = true}

math.randomseed(os.time())

function love.load()
    love.graphics.setDefaultFilter('nearest')
    basBackdrop = love.graphics.newImage("backdrop.png")
    basicPallet = love.graphics.newImage("pallet.png")
    ball = love.graphics.newImage("ball.png")
    alienSheet = love.graphics.newImage("aliens.png")
    for x = 0, 3 do
        local quad = love.graphics.newQuad(0, x * 16,16,16,alienSheet:getWidth(),alienSheet:getHeight())
        table.insert(aliens, quad)
    end
    font = love.graphics.newFont("bitwonder.ttf", 32)
    love.graphics.setFont(font)

    generateAliens(screenWidth / 2 - 144, screenHeight / 2 - 64, 8,6)

end

function love.update(dt)
    if love.keyboard.isDown('w') then
        movePallets(palletLocations.pallet1, palletLocations.pallet2, 8, "up")
    end

    if love.keyboard.isDown('s') then
        movePallets(palletLocations.pallet1, palletLocations.pallet2, 8, "down")
    end

    moveBall(ballLocation, ballDir, 4)
    ballCollide(ballLocation, ballDir, 16, palletLocations.pallet1, palletLocations.pallet2)
    hitAttack()
    deltaClock = deltaClock + dt
    if deltaClock > 0.05 then
        ballLocation.r = ballLocation.r + 0.5
        
        deltaClock = deltaClock - 0.05
    end    
    enemyDeltaClock = enemyDeltaClock + dt
    if enemyDeltaClock > 0.5 then
        alienMove()
        enemyDeltaClock = enemyDeltaClock - 0.5
    end
    enemyAttackClock = enemyAttackClock + dt
    if enemyAttackClock > 3 then
        alienAttack()
        enemyAttackClock = enemyAttackClock - 3
    end
end

function love.draw()
    love.graphics.draw(basBackdrop, 0, 0)
    
    love.graphics.rectangle('fill', screenWidth / 2 - 20, 10, 20, 60)
    drawPallets(basicPallet, palletLocations.pallet1)
    drawPallets(basicPallet, palletLocations.pallet2)
    drawBall(ball, ballLocation)

    love.graphics.printf(score, screenWidth / 4, 15, 96, 'center')
    love.graphics.printf(score2, screenWidth / 4 * 2.70, 15, 96, 'center')

    drawAlienGrid()
    drawAttack()
    
end

function drawPallets(palletGraphic,pallet)
    love.graphics.draw(palletGraphic, pallet.x, pallet.y, pallet.rot, pallet.w, pallet.h)
end

function drawBall(ballGraphic, ball)
    love.graphics.draw(ballGraphic, ball.x, ball.y, ball.r, 1, 1, ballGraphic:getWidth() / 2, ballGraphic:getHeight() / 2)
end

function movePallets(pallet1, pallet2, palletMove, case)
    if case == "up" then
        pallet1.y = pallet1.y - palletMove
        pallet2.y = pallet2.y + palletMove
    elseif case == "down" then
        pallet1.y = pallet1.y + palletMove
        pallet2.y = pallet2.y - palletMove
    end
end

function moveBall(ball, ballDirs, speed)
    if ballDirs.up then
        ball.y = ball.y - speed
    end
    if ballDirs.down then
        ball.y = ball.y + speed
    end
    if ballDirs.left then
        ball.x = ball.x - speed
    end
    if ballDirs.right then
        ball.x = ball.x + speed
    end
end

function ballCollide(ball, ballDirs, ballOffset, pallet, pallet2)
    if ball.x >= screenWidth - ballOffset then
        ball.x = screenWidth / 4
        ball.y = screenHeight / 2
        ballDirs.left = true
        ballDirs.right = false
        score = score + 1
    elseif ball.x <= 0 + ballOffset then
        ball.x = screenWidth / 1.5
        ball.y = screenHeight / 2
        ballDirs.left = false
        ballDirs.right = true
        score2 = score2 + 1
    elseif ball.y >= screenHeight - ballOffset then
        ballDirs.up = true
        ballDirs.down = false
    elseif ball.y <= 0 + ballOffset then
        ballDirs.up = false
        ballDirs.down = true
    end

    if ball.y >= pallet.y and ball.y <= pallet.y + basicPallet:getHeight() * 2 then
        if ball.x <= pallet.x + basicPallet:getWidth() + ballOffset then
            ballDirs.left = false
            ballDirs.right = true
        end
    end

    if ball.y >= pallet2.y and ball.y <= pallet2.y + basicPallet:getHeight() * 2 then
        if ball.x >= pallet2.x + basicPallet:getWidth() - ballOffset then
            ballDirs.left = true
            ballDirs.right = false
        end
    end

    for z,quad in ipairs(genAliens) do
        if ball.y >= quad.y and ball.y <= quad.y + 32 then
            if ball.x >= quad.x and ball.x <= quad.x + 32 then
                --genAliens[z] = nil
                --alienBullets[z] = nil
            end
        end
    end

end

function generateAliens(posX, posY, numX, numY)
    for x = 1, numX do 
        for y = 1, numY do
            local posX = posX + (32 * x) - 32
            local posY = posY + (32 * y) - 32
            local type = math.random(1,4)
            local isDead = false 
            local alienOpt = {x = posX, y = posY, type = type, dead = isDead}
            table.insert(genAliens, alienOpt)

            local readyBullet = {x = posX, y = posY, shot = false, dir = math.random(0,1)}
            table.insert(alienBullets, readyBullet)
        end
    end 
end

function drawAlienGrid()
    local drawStack = {}
    local stack = {x = 0,y = 0,type = 0}
    for z,quad in ipairs(genAliens) do
        table.insert(drawStack, quad)
        stack.x = drawStack[z].x
        stack.y = drawStack[z].y
        stack.type = drawStack[z].type
        love.graphics.draw(alienSheet,aliens[stack.type],stack.x, stack.y, 0, 2, 2)
    end
end

function alienMove()
    local nextMove = math.random(-2, 2) * 4
    for z,quad in ipairs(genAliens) do
        quad.y = quad.y + nextMove
    end
end

function alienAttack()
    for z,quad in ipairs(genAliens) do
        moveAttempt = math.random(1, 10)
        if moveAttempt == 1 then
            alienBullets[z].shot = true 
        else
            alienBullets[z].x = quad.x 
            alienBullets[z].y = quad.y 
        end
    end
end

function drawAttack()
    for z,bullet in ipairs(alienBullets) do
        if bullet.shot then
            love.graphics.rectangle('fill', bullet.x + 2, bullet.y + 4, 8, 4)
            if bullet.dir == 0 then
                bullet.x = bullet.x - 4
            else
                bullet.x = bullet.x + 4
            end
            if bullet.x <= 0 then
                bullet.x = genAliens[z].x
                bullet.y = genAliens[z].y
                bullet.shot = false
            end
        end
    end
end

function hitAttack()
    for z,bullet in ipairs(alienBullets) do
        for p, pallet in ipairs(palletLocations) do
            if bullet.y >= pallet.y and bullet.y <= pallet.y + basicPallet:getHeight() * 2 then
                if bullet.x <= pallet.x then
                    bullet.x = genAliens[z].x
                    bullet.y = genAliens[z].y
                    bullet.shot = false
                    pallet.health = pallet.health - 50
                    print(pallet.health)
                end
            end
            if pallet.health <= 0 then
                table.remove(palletLocations, pallet)
            end
        end
    end
end


