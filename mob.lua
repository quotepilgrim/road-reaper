Mob = {}
Mob.__index = Mob

function Mob:load(params)
    local self = {}
    setmetatable(self, Mob)
    self.x = params.x
    self.y = params.y
    self.sprites = {
        ["mob"] = love.graphics.newImage("assets/mob.png"),
        ["ghost"] = love.graphics.newImage("assets/ghost.png"),
    }
    self:set_sprite("mob")
    self.speed = params.speed or 200
    self.state = "alive"
    self.points = 0
    self.timer = 0
    self.next_pause = self.randomize_pause()
    self.pause_duration = 0
    self.pulse = 0
    self.shiny = false
    self.death_sound = love.audio.newSource("assets/mob_die.wav", "static")
    self.collect_sounds = { 
        normal = love.audio.newSource("assets/collect_soul.wav", "static"),
        shiny = love.audio.newSource("assets/collect_shiny.wav", "static")
    }

    return self
end

-- states --

Mob.alive = {}
Mob.dead = {}
Mob.waiting = {}

-- alive state methods --

function Mob.alive:update(dt)
    self.pulse = math.fmod(self.pulse + dt*5, math.pi)
    if self.pause_duration > 0 then
        self.pause_duration = self.pause_duration - dt
    else
        self.y = self.y + self.speed * dt
        self.next_pause = self.next_pause - dt

        if self.next_pause <= 0 then
            self.next_pause = self.next_pause + self.randomize_pause()
            self.pause_duration = math.random(1,10)/10
        end
    end

    if self.y > 600 then
        self.y = -self.height
    end
end

function Mob.alive:draw()
    local pulse_sin
    if self.shiny then
        pulse_sin = 0.8 + 0.2 * math.sin(self.pulse)
        love.graphics.setColor(1, pulse_sin, pulse_sin, 1)
    end
    love.graphics.draw(self.sprite, self.x, self.y)
    love.graphics.setColor(1, 1, 1, 1)
end

function Mob.alive:die()
    if self.shiny then
        self.timer = 1
    else
        self.timer = 1.5
    end
    self.speed = 50
    self:set_sprite("ghost")
    self.death_sound:play()
    self.state = "dead"
end

-- dead state methods --

function Mob.dead:update(dt)
    self.y = self.y - self.speed * dt
    self.timer = self.timer - dt
    if self.timer < 0 then
        self.timer = 1
        self.state = "waiting"
    end
end

function Mob.dead:draw()
    local blue
    if self.shiny then
        blue = .6
    else
        blue = 1
    end
    love.graphics.setColor(1, 1, blue, math.min(1, 2 * self.timer))
    love.graphics.draw(self.sprite, self.x, self.y)
    love.graphics.setColor(1, 1, 1, 1)
end

function Mob.dead.die() end

-- waiting state methods --

function Mob.waiting:update(dt)
    self.timer = self.timer - dt
    if self.timer < 0 then
        self:respawn()
    end
end

function Mob.waiting.draw()
end

function Mob.waiting.die()
end

---

function Mob:update(dt)
    Mob[self.state].update(self, dt)
end

function Mob:draw()
    Mob[self.state].draw(self)
end

function Mob:collide(obj, source)
    local margin = 10
    local collision = self.x+margin < obj.x+obj.width and
                self.x+self.width-margin > obj.x and
                self.y+margin < obj.y+obj.height and
                self.y+self.height-margin > obj.y
    return collision
end

function Mob:die()
    Mob[self.state].die(self)
end

function Mob:respawn()
    if math.random(0,99) < 10 then
        self.shiny = true
    else
        self.shiny = false
    end
    self:randomize_speed()
    self.y = -self.height
    self:set_sprite("mob")
    self.state = "alive"
end

function Mob:randomize_speed()
    self.speed = math.random(-3,3)*20 + 140
end

function Mob:randomize_pause()
    return math.random(2,7)/2
end

function Mob:set_sprite(sprite)
    self.sprite = self.sprites[sprite]
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
end

function Mob:collect()
    if self.shiny then
        self.points = 5
        self.collect_sounds["shiny"]:play()
    else
        self.points = 1
        self.collect_sounds["normal"]:play()
    end
    self.timer = 1
    self.state = "waiting"
end