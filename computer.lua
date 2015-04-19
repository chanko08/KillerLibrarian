local Component = require 'component'
local Vector = require 'lib/hump/vector'
local inspect = require 'lib/inspect'
local ComputerTileset = {}
ComputerTileset.default = 2
ComputerTileset.broken = {14,2}

ComputerTileset.explosion = {}
ComputerTileset.explosion[{0,0}]  = { {48,72,75}, -2}
ComputerTileset.explosion[{1,0}]  = { {49,73,76}, -2}
ComputerTileset.explosion[{-1,0}] = { {47,71,74}, -2}
ComputerTileset.explosion[{0,-1}] = { {38,62,65}, -2}
ComputerTileset.explosion[{0,1}]  = { {58,82,85}, -2}

local explosion_sound = love.audio.newSource('assets/explosion.wav',"static")

local function screen_shake(world, duration)
    local e = {}
    e.shake = {}
    e.shake.time = 0
    e.shake.duration = duration or 0
    e.shake.translation = Vector(0,0)


    world:add(e)
end


local function make_computer_explosion( world, collision, tileset, computer )
    collision:remove(computer)
    computer.sprite.tile = tileset[ComputerTileset.broken[1]]
    computer.sprite.tile.z = ComputerTileset.broken[2]
    computer.checked = true
    screen_shake(world, 2)
    local center = computer.sprite.pos
    for rel, tid in pairs(ComputerTileset.explosion) do
        local tids, z = unpack(tid)
        local e = {}
        e.animation = {}
        e.animation.tiles = {}
        e.animation.delay = 1/10
        e.animation.time = 0
        e.animation.frame = 1
        e.animation.full_time = 0
        e.animation.duration = 2
        e.animation.done = false
        for i, tid in pairs(tids) do
            local tile = tileset[tid]
            table.insert(e.animation.tiles, tile)
        end

        e.sprite = {}
        e.sprite.tile = e.animation.tiles[1]
        local dim = Vector(e.sprite.tile.width, e.sprite.tile.height)
        e.sprite.pos = center + Vector(unpack(rel)):permul(dim)
        e.sprite.z = z
        e.is_explosion = true
        e.push_direction = Vector(unpack(rel))

        e.collision = {}
        e.collision = {}
        e.collision.width = dim.x
        e.collision.height = dim.y
        e.collision.offset = Vector(0,0)


        collision:add(
            e,
            e.sprite.pos.x,
            e.sprite.pos.y,
            e.collision.width,
            e.collision.height
        )


        world:add(e)
    end

    explosion_sound:play()
    world:remove(computer)
    computer.collision = nil
    world:add(computer)
end

local function make_computer( tileset, index, level_width, level_height )
    -- body
    local computer = {}
    computer.sprite = Component.sprite(tileset, ComputerTileset.default, index, level_width, level_height)

    computer.is_computer = true
    computer.explode = false
    computer.explode_delay = 0
    computer.collision = Component.collision(computer.sprite.tile.width, computer.sprite.tile.height)

    return computer
end

local function computer_action(world, collision, dt)


    for i,e in ipairs(world:get("is_computer", "collision")) do
        local x, y, cols, num_cols = collision:check(e, e.sprite.pos.x, e.sprite.pos.y)


        if num_cols > 0 and not e.checked then
            if e.explode_delay <= 0 then
                make_computer_explosion(world, collision, world.tileset, e)
            else
                e.explode_delay = e.explode_delay - dt
            end
        elseif e.explode then
            if e.explode_delay <= 0 then
                make_computer_explosion(world, collision, world.tileset, e)
            else
                e.explode_delay = e.explode_delay - dt
            end
        end
    end
end

return {
    new = make_computer,
    update = computer_action
}
