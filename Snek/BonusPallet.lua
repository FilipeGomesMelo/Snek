BonusPallet = Class{}

function BonusPallet:init()
    self.active = false
    self.activeTimer = 0 
    self.x = 0
    self.y = 0
end

function BonusPallet:update()
    if self.active == true then
    self.activeTimer = self.activeTimer + 100
        if self.activeTimer >= 50000 then
            self.activeTimer = 0
            self.active = false
            self.x = 0
            self.y = 0
        end
    end
end

function BonusPallet:newBonusPallet()
    if self.active == false then
        powerup_reveal:play()
        self.x = math.random(1, 46) * 9
        self.y = math.random(1, 25) * 9
        self.active = true 
    end
end

function BonusPallet:render()
    love.graphics.setColor(240/255, 79/255, 83/255, 255/255)
    if self.active == true then
        love.graphics.rectangle('line', self.x + 2, self.y + 2, 5, 5)
        love.graphics.setColor(255/255, 28/255, 36/255, 255/255)
        love.graphics.rectangle('fill', self.x + 3, self.y + 3, 3, 3)
    end
end