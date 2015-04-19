local Component = require 'component'
local inspect = require 'lib/inspect'
local _ = require 'lib/underscore'
local Vector = require 'lib/hump/vector'
local PatronTileset = {}
PatronTileset.default = 3
PatronTileset.dead    = 13
PatronTileset.bloodpool = {}
PatronTileset.bloodpool[{-1,0}] = 44
PatronTileset.bloodpool[{1,0}] = 46
PatronTileset.bloodpool[{0,0}] = 45
PatronTileset.bloodpool[{0,-1}] = 35
PatronTileset.bloodpool[{0,1}] = 55


local death_effect = love.audio.newSource('assets/dead_person.wav',"static")

local function make_patron_death( world, collision, tileset, patron )
    collision:remove(patron)
    patron.sprite.tile = tileset[PatronTileset.dead]
    patron.sprite.z = -1
    patron.checked = true

    local center = patron.sprite.pos
    for rel, tid in pairs(PatronTileset.bloodpool) do
        local e = {}
        e.sprite = {}
        e.sprite.tile = tileset[tid]
        local dim = Vector(e.sprite.tile.width, e.sprite.tile.height)
        e.sprite.pos = center + Vector(unpack(rel)):permul(dim)
        e.sprite.z = -2

        world:add(e)
    end

    world:remove(patron)
    patron.collision = nil
    world:add(patron)
    death_effect:play()
end

local function make_patron(tileset, index, level_width, level_height )
    local patron = {}

    patron.sprite = Component.sprite(tileset, PatronTileset.default, index, level_width, level_height)
    -- patron.sprite.tile = tileset[PatronTileset.default]
    -- patron.sprite.pos = util.tileIndexToPosition(i, w, h, patron.sprite.tile.width, patron.sprite.tile.height)

    patron.is_patron = true

    patron.collision = Component.collision(patron.sprite.tile.width, patron.sprite.tile.height)
    -- patron.collision.width = patron.sprite.tile.width
    -- patron.collision.height = patron.sprite.tile.height
    return patron
end

local function patron_action( world, collision, dt)
    for i,e in ipairs(world:get("is_patron")) do
        local x, y, cols, num_cols = collision:check(e, e.sprite.pos.x, e.sprite.pos.y)

        if num_cols > 0 and not e.checked then
            make_patron_death(world, collision, world.tileset, e)
            

            e.sprite.tile = world.tileset[PatronTileset.dead]
            e.checked =true

            local e2 = {}
            e2.sprite = e.sprite

           
            world:remove(e)
            world:add(e2)

        end
    end
end

return {
    new = make_patron,
    update = patron_action
}