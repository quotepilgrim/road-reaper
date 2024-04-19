Car = {}
Car.__index = Car

function Car:load(params)
    local self = {}
    setmetatable(self, Car)
    self.x = params.x
    self.y = params.y
    self.speed = params.speed or 100
    self.sprites = {
        love.graphics.newImage("assets/car_red.png"),
        love.graphics.newImage("assets/car_yellow.png"),
        love.graphics.newImage("assets/car_green.png"),
        love.graphics.newImage("assets/car_cyan.png"),
        love.graphics.newImage("assets/car_blue.png"),
        love.graphics.newImage("assets/car_magenta.png"),
    }
    self:set_sprite()
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
    return self
end

function Car:update(dt)
    self.x = self.x + self.speed * dt
    if self.speed > 0 and self.x > 800 or self.speed < 0 and self.x < -self.width then
        self:reset()
    end
end

function Car:draw()
    if self.speed > 0 then
        love.graphics.draw(self.sprite, self.x, self.y, 0)
    else
        love.graphics.draw(self.sprite, self.x, self.y, 0, -1, 1, self.width)
    end
end

function Car:reset()
    self:set_sprite()
    local speed = math.random(3, 12) * 45
    if self.speed > 0 then
        self.x = -self.width * 3
    else
        speed = -speed
        self.x = 800 + self.width * 2
    end
    self.speed = speed
end

function Car:set_sprite()
    self.sprite = self.sprites[math.random(1, #self.sprites)]
end

