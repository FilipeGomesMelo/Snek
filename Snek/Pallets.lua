Pallets = Class{}

function Pallets:init()
    self:newPallet(1)
end

function Pallets:newPallet(n)
    self.n = n
    self.x = {}
    self.y = {}
    local i = 1 
    while i <= self.n do
        local auxX = math.random(1, 46) * 9
        local auxY = math.random(1, 25) * 9
        if not (self:palletExists(auxX, auxY)) then
            self.x[i] = auxX
            self.y[i] = auxY
            i = i + 1
        end
    end
end

function Pallets:atePallet(x, y)
    for i = 1, self.n do
        if x == self.x[i] and y == self.y[i] then
            self.x[i] = -10
            self.y[i] = -10
        end
    end
end

function Pallets:render()
    love.graphics.setColor(43/255, 51/255, 26/255, 255/255)
    for i = 1, self.n do
        love.graphics.rectangle('fill', self.x[i] + 2, self.y[i] + 2, 5, 5)
    end
    
end

function Pallets:palletExists(x, y)
    for i = 1, self.n do
        if self.x[i] == x and self.y[i] == y then
            return true
        end
    end

    return false
end