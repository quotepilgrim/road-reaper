require "player"
require "car"
require "mob"
require "clock"

local push = require "lib.push"

local delay, timer, key_pressed
local score_height, time_width, header_height, body_width, body_height, line
local score_text, game_over_text, controls_text, title_text, start_text
local time_text, restart_text, control_strings, time_color
local small_font = love.graphics.newFont(24)
local big_font = love.graphics.newFont(32)

local width, height = 800, 600
local window_width = select(1,love.window.getDesktopDimensions())
local window_height = select(2,love.window.getDesktopDimensions())
local player, cars, mobs, clock
local bg = love.graphics.newImage("assets/bg.png")
local beepbeep = love.audio.newSource("assets/beepbeep.wav", "static")

local screen = "title"
local screens = {
    title = {},
    main = {},
    game_over = {}
}

local function load_objects()
    player = Player:load{x=400, y=535, width=24, height=24}
    timer = 15

    player.x = player.x -player.width/2

    mobs = {
        Mob:load{x=100, y=-50},
        Mob:load{x=250, y=-50},
        Mob:load{x=400, y=-50},
        Mob:load{x=550, y=-50},
        Mob:load{x=700, y=-50},
    }

    cars = {
        Car:load{x=0, y=94},
        Car:load{x=0, y=144, speed=-1},
        Car:load{x=0, y=258},
        Car:load{x=0, y=306, speed=-1},
        Car:load{x=0, y=420},
        Car:load{x=0, y=470, speed=-1},
    }

    clock = Clock:load()

    for i in pairs(cars) do
        if cars[i].x == 0 then
            cars[i]:reset()
        end
    end

    for i in pairs(mobs) do
        mobs[i].x = mobs[i].x - mobs[i].width/2
        mobs[i]:randomize_speed()
    end
end

local function reset()
    player = nil
    clock = nil

    for i in pairs(cars) do
        cars[i] = nil
    end

    for i in pairs(mobs) do
        mobs[i] = nil
    end
end

local function game_over()
    delay = 0
    key_pressed = false
    player.death_sound:play()
    screen = "game_over"
end

-- title screen --

function screens.title.update(dt)
    delay = 0
    if key_pressed then
        screen = "main"
    end
end

function screens.title.draw()

    controls_text.body:set(control_strings.wasd)
    header_height = controls_text.header:getHeight()
    body_width, body_height = controls_text.body:getDimensions()

    line = 160
    love.graphics.draw(
        title_text, 400, line, 0, 1, 1, title_text:getWidth()/2, header_height)

    line = line + 100
    love.graphics.draw(controls_text.header, 400-body_width/2, line, 0, 1, 1)

    line = line + header_height * 1.6
    love.graphics.draw(controls_text.body, 400, line, 0, .8, .8, body_width/2)

    controls_text.body:set(control_strings.escape)

    line = line + body_height * 1.2
    love.graphics.draw(controls_text.body, 400, line, 0, .8, .8, body_width/2)

    love.graphics.draw(
        start_text, 400, 500, 0, .8, .8, start_text:getWidth()/2
    )
end

-- main screen --

function screens.main.update(dt)
    player:update(dt)
    clock:update(dt)
    score_text:set("Score: "..player.score)

    timer = timer - dt

    if timer < 5 then
        time_color = {1, .4, .3}
        beepbeep:play()
    else
        time_color = {1, 1, 1}
    end

    time_text:set({
        {1,1,1}, "Time: ", time_color, string.format("%.2f", timer)
    })

    if timer < 0 then
        game_over_text:set("Time's up!")
        game_over()
    end

    for i in pairs(cars) do
        if player:collide(cars[i]) then
            game_over_text:set("You died!")
            game_over()
        end
        cars[i]:update(dt)
    end

    for i in pairs(mobs) do
        for j in pairs(cars) do
            if mobs[i]:collide(cars[j]) then
                mobs[i]:die()
            end
        end

        if mobs[i]:collide(player) then
            if mobs[i].state == "dead" then
                mobs[i]:collect()
                player.score = player.score + mobs[i].points
            end
        end

        if player:collide(clock) then
            if clock.state == "visible" then
                timer = timer + 5
                if timer > 99 then
                    timer = 99
                end
                clock.collect_sound:play()
                clock:hide()
            end
        end

        mobs[i]:update(dt)
    end
end

function screens.main.draw()
    love.graphics.draw(bg, 0, 0, 0)

    clock:draw()

    for i in pairs(cars) do
        cars[i]:draw()
    end

    for i in pairs(mobs) do
        mobs[i]:draw()
    end

    love.graphics.draw(score_text, 10, height-10, 0, .8, .8, 0, score_height)
    love.graphics.draw(time_text, width-10, height-10, 0, .8, .8, time_width, score_height)

    player:draw()
end

-- game over screen --

function screens.game_over.update(dt)
    delay = delay + dt
    if key_pressed and delay > .5 then
        reset(); load_objects()
        screen = "main"
    end
end

function screens.game_over.draw()
    love.graphics.draw(
        game_over_text, 400, 200, 0, 1, 1,
        game_over_text:getWidth()/2, game_over_text:getHeight()
    )
    love.graphics.draw(score_text, 400, 250, 0, 1, 1, score_text:getWidth()/2)
    love.graphics.draw(
        restart_text, 400, 450, 0, .8, .8,
        restart_text:getWidth()/2
    )
end

----------------
-- game start --
----------------

function love.load()
    window_width, window_height = window_width * 0.8, window_height * 0.8
    if window_height >= window_width then
        window_height = 3/4 * window_width
    else
        window_width = 4/3 * window_height
    end

    push:setupScreen(
        width, height, window_width, window_height,
        {resizable=true, canvas=false}
    )

    title_text = love.graphics.newText(big_font, "Road Reaper")
    start_text = love.graphics.newText(
        small_font,{{.5, .5, .5},"Press any key to begin."}
    )
    controls_text = {
        header = love.graphics.newText(small_font, "Controls:"),
        body = love.graphics.newText(small_font,""),
    }
    control_strings = {
        wasd = "W, A, S, D or arrow keys to move",
        escape = "Escape to exit"
        }
    score_text = love.graphics.newText(small_font, "Score")
    time_text = love.graphics.newText(small_font, "Time: 99.99")
    restart_text = love.graphics.newText(
        small_font, {{.5, .5, .5}, "Press any key to restart."}
    )
    game_over_text = love.graphics.newText(big_font, "Game Over")
    score_height = score_text:getHeight()
    time_width = time_text:getWidth()

    load_objects()
end

function love.update(dt)
    screens[screen].update(dt)
end

function love.draw()
    push:start()
    screens[screen].draw()
    push:finish()
end

--- *** ---

function love.resize(w, h)
    return push:resize(w, h)
end

function love.keypressed(key, scancode, isrepeat)
    key_pressed = true
    if key == "escape" then
        love.event.quit()
    end
end

function love.keyreleased(key, scancode, isrepeat)
    key_pressed = false
end