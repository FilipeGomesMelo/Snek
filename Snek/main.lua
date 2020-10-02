Class = require 'class'
push = require 'push'

require 'Pallets'
require 'Player'
require 'BonusPallet'



pallets = Pallets()
bonusPallet = BonusPallet()
player = Player()

-- close resolution to NES but 16:9
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- actual window resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- playable area 9 < x < 423 and 9 < y < 234, width = 414, height = 225 
-- 46 tiles x 25 tiles


-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')

-- seed RNG
math.randomseed(os.time())

-- performs initialization of all objects and data needed by program
function love.load()
    
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    largeFont = love.graphics.newFont('fonts/font.ttf', 16)
    love.graphics.setFont(smallFont)

    timer = 0

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    love.window.setTitle('Nokia Snake')

    highScore = 0

    menuY = {25, 35, 45, 55}

    bordersOn = 'on'
    bonusOn = 'on'
    
    pointer = 1
    
    score = love.audio.newSource('sounds/score.wav', 'static')
    death = love.audio.newSource('sounds/death.wav', 'static')
    powerup_reveal = love.audio.newSource('sounds/powerup-reveal.wav', 'static')
    pickup = love.audio.newSource('sounds/pickup.wav', 'static')

    gameState = 'start'

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

function love.keypressed(key)
    -- quiting
    if key == 'escape' then
        love.event.quit()
    -- debuging
    --[[elseif gameState == 'play' and key == 'space' then
        pallets:newPallet(1)
        score:play()
        player:increaseLength()
    elseif gameState == 'play' and key == 'b' then
        pallets:newPallet(30)
        player.bonusTimer = 0
        player.bonus = true]]
    elseif gameState == 'start' then
        if key == 'enter' or key == 'return' then
            if pointer == 1 then
                gameState = 'play'
                pallets:init()
                player:init()
                bonusPallet:init()
            elseif pointer == 2 then 
                if bonusOn== 'on' then
                    bonusOn = 'off'
                else 
                    bonusOn = 'on'
                end
            elseif pointer == 3 then 
                if bordersOn == 'on' then
                    bordersOn = 'off'
                else 
                    bordersOn = 'on'
                end
            elseif pointer == 4 then 
                if playTimeOn == 'on' then
                    playTimeOn = 'off'
                else 
                    playTimeOn = 'on'
                end
            end
        elseif key == 'w' then
            if pointer == 1 then
                pointer = 3
            else
                pointer = pointer - 1 
            end
        elseif key == 's' then
            if pointer == 3 then
                pointer = 1
            else
                pointer = pointer + 1 
            end
        end
    elseif gameState == 'play' and (key == 'enter' or key == 'return') then
        gameState = 'pause'
    elseif gameState == 'pause' and (key == 'enter' or key == 'return') then
        gameState = 'play'
    end

    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- called every frame, with dt passed in as delta in time since last frame
function love.update(dt)
    if gameState == 'play' then
        player:update(dt)
        bonusPallet:update()
    end
    if player.length > highScore then
        highScore = player.length
    end
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
    timer = timer + 1
end

-- called each frame, used to render to the screen
function love.draw()
    -- begin virtual resolution drawing
    push:apply('start')

    -- clear screen using Mario background blue
    love.graphics.clear(167/255, 201/255, 100/255, 255/255)
    
    -- drawing borders
    if bordersOn == 'on' then
        love.graphics.setColor(43/255, 51/255, 26/255, 255/255)
        love.graphics.rectangle('fill', 4, 4, 5, 235)
        love.graphics.rectangle('fill', 4, 4, 424, 5)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH - 9, 4, 5, 235)
        love.graphics.rectangle('fill', 4, VIRTUAL_HEIGHT - 9, 424, 5)
    else
        love.graphics.setColor(43/255, 51/255, 26/255, 255/255)
        love.graphics.rectangle('fill', 7, 7, 2, 229)
        love.graphics.rectangle('fill', 7, 7, 418, 2)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH - 9, 7, 2, 229)
        love.graphics.rectangle('fill', 7, VIRTUAL_HEIGHT - 9, 418, 2)
    end
    -- creates a grid to help with alignment
    --[[love.graphics.setColor(157/255, 191/255, 90/255, 255/255)
        x = 9
    aux = 0
    while x <= 414 do
        if (aux % 2) == 1 then 
            y = 9
        else 
            y = 18
        end
        while y <= 225 do
            love.graphics.rectangle('fill', x, y, 9, 9)
            y = y + 18
        end
        x = x + 9
        aux = aux + 1
    end]] 

    love.graphics.setColor(43/255, 51/255, 26/255, 255/255)

    if gameState == 'start' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('WELCOME TO SNEK!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('START!', 0, 25, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Bonus:   ' .. tostring(bonusOn), 0, 35, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Borders: ' .. tostring(bordersOn), 0, 45, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('>', -30, menuY[pointer], VIRTUAL_WIDTH, 'center')
    else
        bonusPallet:render()
        pallets:render()
        player:render()
        if gameState == 'play' then
            love.graphics.printf('Score: ' .. tostring(player.length - 2), 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('High Score: ' .. tostring(highScore - 2), 0, 20, VIRTUAL_WIDTH, 'center')
        elseif gameState == 'pause' then
            love.graphics.printf('PAUSED', 0, 20, VIRTUAL_WIDTH, 'center')
        end    
    end

    push:apply('end')
end