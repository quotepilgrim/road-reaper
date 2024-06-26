Clock = {}
Clock.__index = Clock

function Clock:load()
    local self = {}
    setmetatable(self, Clock)
    self.x = 0
    self.y = 0
    self.sprite = love.graphics.newImage("assets/clock.png")
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
    self.state = "hidden"
    self.states = {
        visible = {},
        hidden = {},
    }
    self.timer = 3
    self.place = {
        x = { 100, 280, 520, 700 },
        y = { 32, 200, 364, 532 },
    }
    self.collect_sound = love.audio.newSource("assets/collect_clock.wav", "static")

    function self.states.visible.update(dt)
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self:hide()
        end
    end

    function self.states.visible.draw()
        love.graphics.setColor(1, 1, 1, 2 * math.min(1, 2 * self.timer))
        love.graphics.draw(self.sprite, self.x, self.y)
        love.graphics.setColor(1, 1, 1, 1)
    end

    function self.states.hidden.update(dt)
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self:spawn()
        end
    end

    function self.states.hidden.draw() end

    return self
end

function Clock:update(dt)
    self.states[self.state].update(dt)
end

function Clock:draw()
    self.states[self.state].draw()
end

function Clock:spawn()
    local x = math.random(1, #self.place.x)
    local y
    if x > 1 and x < #self.place.x then
        y = math.random(1, #self.place.y)
    else
        y = math.random(1, #self.place.y - 1)
    end
    self.x = self.place.x[x]
    self.y = self.place.y[y]
    self.timer = 2.25
    self.state = "visible"
end

function Clock:hide()
    self.timer = math.random(4, 10) / 2
    self.state = "hidden"
end
