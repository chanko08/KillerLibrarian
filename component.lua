local Util = require 'util'
local Vector = require 'lib/hump/vector'

local function make_collision(w, h, offset)
    local c = {}
    c.width = w
    c.height = h
    c.offset = offset or Vector(0,0)
    return c
end

local function make_sprite( tileset, tileset_index , index, level_width, level_height )
    sprite      = {}
    sprite.tile = tileset[tileset_index]
    sprite.pos  = Util.tileIndexToPosition(
        index,
        level_width,
        level_height,
        sprite.tile.width,
        sprite.tile.height
    )

    sprite.z = 0

    return sprite
end


local function make_animation( tiles, fps )
    animation = {}
    animation.tiles = tiles
    animation.fps = fps
end

return {
    collision = make_collision,
    sprite    = make_sprite
}