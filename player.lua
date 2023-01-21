Player = {}
Player.__index = Player

function Player:load(params)
    local self = {}
    setmetatable(self, Player)
    self.x = params.x
    self.y = params.y
    self.sprite=love.graphics.newImage("assets/player.png")
    self.width=self.sprite:getWidth()
    self.height=self.sprite:getHeight()
    self.speed = params.speed or 300
    self.score = 0
    self.death_sound = love.audio.newSource("assets/player_die.wav", "static")
    return self
end

function Player:update(dt)
    if love.keyboard.isDown("w", "up", "kp8") then
        self.y = self.y - self.speed * dt

        if self.y < 0 then
            self.y = 0
        end
    end

    if love.keyboard.isDown("s", "down", "kp2") then
        self.y = self.y + self.speed * dt

        local limit = 600 - self.width

        if self.y > limit then
            self.y = limit
        end
    end

    if love.keyboard.isDown("a", "left", "kp4") then
        self.x = self.x - self.speed * dt

        if self.x < 0 then
            self.x = 0
        end
    end

    if love.keyboard.isDown("d", "right", "kp6") then
        self.x = self.x + self.speed * dt

        local limit = 800 - self.width

        if self.x > limit then
            self.x = limit
        end
    end
end

function Player:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
end

--- *** ---

function Player:collide(obj)
    local margin = 10
    local collision = self.x+margin < obj.x+obj.width and
                      self.x+self.width-margin > obj.x and
                      self.y+margin < obj.y+obj.height and
                      self.y+self.height-margin > obj.y
    return collision
end