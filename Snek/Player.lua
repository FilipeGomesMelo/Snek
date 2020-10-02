Player = Class{}

local SPEED = 5

function Player:init(x, y)
    -- possition
    self.x = {}
    self.y = {} 
    self.x[1] = 90
    self.y[1] = 90
    self.x[2] = 81
    self.y[2] = 90
    self.length = 2

    self.eatenPallets = 0
    self.bonusTimer = 0

    -- shape 
    self.width = 7
    self.height = 7

    -- movement
    self.dx = 9
    self.dy = 0
    self.timer = 0

    self.moved = false

    -- state
    self.state = 'right'

    -- behaviors that change depending on the state
    self.behaviors = {
        --moving up
        ['up'] = function(dt)
            self.dx = 0
            self.dy = -9
            if love.keyboard.wasPressed('a') then
                self.moved = false
                self.state = 'left'
            elseif love.keyboard.wasPressed('d') then
                self.moved = false
                self.state = 'right'
            end
        end,
        --moving down
        ['down'] = function(dt)
            self.dx = 0
            self.dy = 9
            if love.keyboard.wasPressed('a') then
                self.moved = false
                self.state = 'left'
            elseif love.keyboard.wasPressed('d') then
                self.moved = false
                self.state = 'right'
            end
        end,
        -- moving left
        ['left'] = function(dt)
            self.dx = -9
            self.dy = 0
            if love.keyboard.wasPressed('w') then
                self.moved = false
                self.state = 'up'
            elseif love.keyboard.wasPressed('s') then
                self.moved = false
                self.state = 'down'
            end
        end,
        -- moving right
        ['right'] = function(dt)
            self.dx = 9
            self.dy = 0
            if love.keyboard.wasPressed('w') then
                self.moved = false
                self.state = 'up'
            elseif love.keyboard.wasPressed('s') then
                self.moved = false
                self.state = 'down'
            end
        end
    }
end

function Player:increaseLength()
    self.x[self.length + 1] = self.x[self.length]
    self.y[self.length + 1] = self.y[self.length]
    self.length = self.length + 1
    if self.length % 5 == 1 and math.random(2) == 1 and bonusOn == 'on' then
        bonusPallet:newBonusPallet()
    end
end

function Player:update(dt)
    self.timer = self.timer + 60 * dt
    if self.timer >= SPEED then
        self.moved = true
        self.timer = 0
        local i = self.length
        while i >= 2 do
            self.x[i] = self.x[i - 1] 
            self.y[i] = self.y[i - 1]
            i = i - 1
        end
        self.x[1] = self.x[1] + self.dx
        self.y[1] = self.y[1] + self.dy
    end
    if self.moved == true then
        self.behaviors[self.state](dt)
    end
    self:hitBorder()
    self:hitPallet()
    self:hitPlayer()
    if self.bonus then
        self.bonusTimer = self.bonusTimer + 60 * dt
        if self.eatenPallets == pallets.n or self.bonusTimer >= 400 then
            self.eatenPallets = 0
            self.bonusTimer = 0
            self.bonus = false
            pallets:newPallet(1)
        end
    end
end

function Player:hitBorder()
    if bordersOn == 'on' then 
        if self.x[1] < 9 or self.x[1] > 414 or self.y[1] < 9 or self.y[1] > 225 then
            self:reset()
        end
    else
        if self.x[1] < 9 then
            self.x[1] = 414
        elseif self.x[1] > 414 then
            self.x[1] = 9
        end
        if self.y[1] < 9 then
            self.y[1] = 225
        elseif self.y[1] > 225 then
            self.y[1] = 9
        end
    end
end

function Player:hitPallet()
    for i = 1, pallets.n do
        if pallets.x[i] == self.x[1] and pallets.y[i] == self.y[1] then
            self.eatenPallets = self.eatenPallets + 1
            pallets:atePallet(self.x[1], self.y[1])
            score:play()
            if self.eatenPallets == pallets.n then
                self.eatenPallets = 0
                pallets:newPallet(1)
            end
            self:increaseLength()
        end
    end
    if bonusPallet.x == self.x[1] and bonusPallet.y == self.y[1] then
        bonusPallet.active = false
        bonusPallet.activeTimer = 0
        pickup:play()
        pallets:newPallet(30)
        player.bonusTimer = 0
        player.bonus = true
    end
end

function Player:hitPlayer()
    for i = 2, self.length do
        if self.x[1] == self.x[i] and self.y[1] == self.y[i] then
            self:reset()
            gameState = 'start'
        end
    end
end

function Player:reset()
    death:play()
    self.x = {}
    self.y = {} 
    self.x[1] = 90
    self.y[1] = 90
    self.x[2] = 81
    self.y[2] = 90
    self.length = 2
    self.state = 'right'
    pallets:newPallet(1)
    bonusPallet.active = false
end

function Player:render()
    love.graphics.setColor(43/255, 51/255, 26/255, 255/255)
    local i = 1
    while i <= self.length do
        love.graphics.rectangle('fill', self.x[i] + 1, self.y[i] + 1, self.width, self.height)
        i = i + 1
    end
end