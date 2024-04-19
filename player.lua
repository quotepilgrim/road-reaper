Player = {}
Player.__index = Player

function Player:load(params)
    local self = {}
    setmetatable(self, Player)
    self.x = params.x
    self.y = params.y
    self.sprite = love.graphics.newImage("assets/player.png")
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
    self.speed = params.speed or 300
    self.score = 0
    self.death_sound = love.audio.newSource("assets/player_die.wav", "static")
    return self
end

function Player:update(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("w", "up", "kp8") then
        dy = dy - 1
    end

    if love.keyboard.isDown("s", "down", "kp2") then
        dy = dy + 1
    end

    if love.keyboard.isDown("a", "left", "kp4") then
        dx = dx - 1
    end

    if love.keyboard.isDown("d", "right", "kp6") then
        dx = dx + 1
    end

    local length = math.sqrt(dx * dx + dy * dy)

    if length > 0 then
        dx, dy = dx / length, dy / length
    end

    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt

    if self.x < 0 then
        self.x = 0
    end
    if self.x > 800 - self.width then
        self.x = 800 - self.width
    end
    if self.y < 0 then
        self.y = 0
    end
    if self.y > 600 - self.height then
        self.y = 600 - self.height
    end
end

function Player:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
end

--- *** ---

function Player:collide(obj)
    local margin = 10
    local collision = self.x + margin < obj.x + obj.width
        and self.x + self.width - margin > obj.x
        and self.y + margin < obj.y + obj.height
        and self.y + self.height - margin > obj.y
    return collision
end

