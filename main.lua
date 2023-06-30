local cases = require "cases"

local square_size = 8
local sample_size = 0.15
local width = 64
local height = 64
local noise_z = 0

local camera_x = 0
local camera_y = 0

local function get_noise(x, y)
    local dx = (x + math.floor(camera_x)) * sample_size
    local dy = (y + math.floor(camera_y)) * sample_size
    return love.math.noise(dx, dy, noise_z)
end

function love.keypressed(key, _, _)
    if key == "r" then
        noise_z = love.math.random(0, 1000000)
    end
end

function love.load()
    love.window.setMode(width*square_size, height*square_size)
end

function love.update(dt)
    if love.keyboard.isDown("=") then
        sample_size = sample_size - 0.1 * dt
    end
    if love.keyboard.isDown("-") then
        sample_size = sample_size + 0.1 * dt
    end

    if sample_size > 0.25 then
        sample_size = 0.25
    elseif sample_size < 0.01 then
        sample_size = 0.01
    end

    local speed = 20
    if love.keyboard.isDown("w") then
        camera_y = camera_y - speed * dt
    end
    if love.keyboard.isDown("a") then
        camera_x = camera_x - speed * dt
    end
    if love.keyboard.isDown("s") then
        camera_y = camera_y + speed * dt
    end
    if love.keyboard.isDown("d") then
        camera_x = camera_x + speed * dt
    end
end

local function dec(x)
    return x - math.floor(x)
end

function love.draw()
    love.graphics.translate(-dec(camera_x) * square_size, -dec(camera_y) * square_size)
    for x = 0, width + 1 do
        for y = 0, height + 1 do
            -- local noise = get_noise(x, y) > 0.5 and 1 or 0
            -- love.graphics.setColor(noise, noise, noise, 0.5)
            -- love.graphics.rectangle("fill", x * square_size, y * square_size, square_size, square_size)
            -- love.graphics.setColor(1, 0, 0, 0.5)
            -- love.graphics.circle("fill", x * square_size, y * square_size, 2)
            -- love.graphics.setColor(1, 1, 1, 1)
            love.math.setRandomSeed(x, y)

            local case_index = 1

            local ul = get_noise(x - 0.5, y - 0.5) < 0.5
            local ur = get_noise(x + 0.5, y - 0.5) < 0.5
            local dl = get_noise(x - 0.5, y + 0.5) < 0.5
            local dr = get_noise(x + 0.5, y + 0.5) < 0.5

            if dl then
                case_index = case_index + 1
            end
            if dr then
                case_index = case_index + 2
            end
            if ur then
                case_index = case_index + 4
            end
            if ul then
                case_index = case_index + 8
            end

            if case_index ~= 0 then
                local case = cases[case_index]
                for _, line in ipairs(case) do
                    local sx, sy = unpack(line[1])
                    local ex, ey = unpack(line[2])

                    sx = x * square_size + sx * square_size
                    sy = y * square_size + sy * square_size
                    ex = x * square_size + ex * square_size
                    ey = y * square_size + ey * square_size

                    love.graphics.line(sx, sy, ex, ey)
                end
            end
        end
    end
end