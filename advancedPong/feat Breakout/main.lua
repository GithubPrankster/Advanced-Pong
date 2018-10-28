local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local deltaClock = 0
local score = 0
local score2 = 0

local controlling = false

local bricks = {}
local brickSpin = {x = 0, y = 0}
local deltaMove = 0

local palletLocations = {pallet1 = {x = 16, y = screenHeight / 2 , w = 2, h = 2, rot = 0, health = 250}, pallet2 = {x = screenWidth - 18 - 16, y = screenHeight / 2, w = 2, h = 2, rot = 0, health = 250}}
local ballLocation = {x = 64, y = 64, r = 0}
local ballDir = {up = false, down = true, left = false, right = true}

math.randomseed(os.time())

function love.load()
    love.graphics.setDefaultFilter('nearest')
    basBackdrop = love.graphics.newImage("backdrop.png")
    basicPallet = love.graphics.newImage("pallet.png")
    ball = love.graphics.newImage("ball.png")

    font = love.graphics.newFont("bitwonder.ttf", 32)
    love.graphics.setFont(font)

    brick1 = love.graphics.newImage("brick.png")
    createBricks(screenWidth / 2 - 128,screenHeight / 2,5,5)
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

    deltaClock = deltaClock + dt
    if deltaClock > 0.05 then
        ballLocation.r = ballLocation.r + 0.5
        
        
        deltaClock = deltaClock - 0.05
    end  
    deltaMove = deltaMove + dt
    if deltaMove > 0.05 then
        local time = love.timer.getTime()
        brickSpin.x = math.sin(time) * 5
        brickSpin.y = math.cos(time) * 5
        
        moveAllBricks(brickSpin.x, brickSpin.y)
        deltaMove = deltaMove - 0.05
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

    drawBricks()
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

    for z, brick in ipairs(bricks) do
        if ball.y >= brick.y and ball.y <= brick.y + brick1:getHeight() then
            if ball.x >= brick.x and ball.x <=  brick.x + brick1:getWidth() and brick.breaky > 0 and ballDirs.right then
                brick.breaky = brick.breaky - 50
                ballDirs.left = true
                ballDirs.right = false
            elseif ball.x >= brick.x and ball.x <=  brick.x + brick1:getWidth() and brick.breaky > 0 and ballDirs.left then
                brick.breaky = brick.breaky - 50
                ballDirs.left = false
                ballDirs.right = true
            end
        end
    end
end

function createBricks(offX, offY,gridX, gridY)
    for x = 1, gridX do 
        for y = 1, gridY do
            local bricky = {x = offX + (64 * x) - 64, y = offY + (32 * y) - 32, type = math.random(0,3), breaky = math.random(1,4) * 50}
            table.insert(bricks, bricky)
        end
    end
end

function drawBricks()
    for z, brick in ipairs(bricks) do
        if brick.breaky > 0 then 
            love.graphics.draw(brick1, brick.x, brick.y)
        end
    end
end

function moveAllBricks(x,y)
    for z, brick in ipairs(bricks) do
        brick.x = brick.x + x
        brick.y = brick.y + y
    end
end



