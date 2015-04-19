local inspect = require 'lib/inspect'
local Component = require 'component'
local Vector = require 'lib/hump/vector'
local _ = require 'lib/underscore'

local shelf = {}

local ShelfTileset = {}
ShelfTileset.default = 1
ShelfTileset.knocked_over = {}
ShelfTileset.knocked_over[{0,0}] = {31, 1}
ShelfTileset.knocked_over[{1,0}] = {32, 1}
ShelfTileset.knocked_over[{2,0}] = {33, 1}

ShelfTileset.knocked_over.left = {}
ShelfTileset.knocked_over.left[{ 0,0}] = {33, 0,  0, 0, 16, 32}
ShelfTileset.knocked_over.left[{-1,0}] = {32, 1,  0, 0, 32, 32}
ShelfTileset.knocked_over.left[{-2,0}] = {31, 1,  16, 0, 16, 32}


ShelfTileset.knocked_over.right = {}
ShelfTileset.knocked_over.right[{0,0}] = {31, 0, 16, 0, 16, 32}
ShelfTileset.knocked_over.right[{1,0}] = {32, 1,  0, 0, 32, 32}
ShelfTileset.knocked_over.right[{2,0}] = {33, 1,  0, 0, 16, 32}

ShelfTileset.knocked_over.up = {}
ShelfTileset.knocked_over.up[{0,0}]  = {42, 0, 0, 0,  32, 16}
ShelfTileset.knocked_over.up[{0,-1}] = {34, 1, 0, 0,  32, 32}
ShelfTileset.knocked_over.up[{0,-2}] = {22, 1, 0, 16, 32, 16}

ShelfTileset.knocked_over.down = {}
ShelfTileset.knocked_over.down[{0,2}] = {42, 0, 0,  0, 32, 16}
ShelfTileset.knocked_over.down[{0,1}] = {34, 1, 0,  0, 32, 32}
ShelfTileset.knocked_over.down[{0,0}] = {22, 1, 0, 16, 32, 16}

local shelf_fall = love.audio.newSource('assets/shelf_fall.wav',"static")

local function make_knocked_over_shelf( world, collision, tileset, shelf )

    local push_direction = shelf.push_direction

    local sprites = ShelfTileset.knocked_over.left
    if push_direction.x > 0 then
        sprites = ShelfTileset.knocked_over.right
    elseif push_direction.y > 0 then
        sprites = ShelfTileset.knocked_over.down
    elseif push_direction.y < 0 then
        sprites = ShelfTileset.knocked_over.up
    end



    --need to change the sprite
    center = shelf.sprite.pos
    for rel, tid in pairs(sprites) do
        local tid, z, xoff, yoff, w, h = unpack(tid)

        local piece = {}
        piece.sprite = {}
        piece.is_shelf_piece = true
        piece.sprite.tile = world.tileset[tid]
        local dim = Vector(piece.sprite.tile.width, piece.sprite.tile.height)

        piece.sprite.pos = center + Vector(unpack(rel)):permul(dim)
        piece.sprite.z   = z
        piece.collision = {}
        piece.collision.width = w or dim.x
        piece.collision.height = h or dim.y
        piece.collision.offset = Vector(xoff, yoff)


        collision:add(
            piece,
            piece.sprite.pos.x + piece.collision.offset.x,
            piece.sprite.pos.y + piece.collision.offset.y ,
            piece.collision.width,
            piece.collision.height
        )


        world:add(piece)
    end

    shelf.fell_over = true
    shelf.push_direction = Vector(0,0)
end

local function make_shelf_piece(tileset, dets, level_width, level_height, i)
    local tid, z, xoff, yoff, w, h = unpack(dets)
    local e = {}
    e.sprite    = Component.sprite(tileset, tid, i, level_width, level_height)
    
    e.collision = Component.collision(w, h)
    e.collision.offset = Vector(xoff, yoff)
    
    return e
end

local function make_shelf(tileset, index, level_width, level_height)
    local e = {}
    e.sprite = Component.sprite(tileset, ShelfTileset.default, index, level_width, level_height)
    e.collision = Component.collision(e.sprite.tile.width, e.sprite.tile.height)

    e.is_shelf  = true
    e.fell_over = false
    e.push_direction = Vector(0,0)
    e.push_delay = 0

    return e
end

local function screen_shake(world, duration)
    local e = {}
    e.shake = {}
    e.shake.time = 0
    e.shake.duration = duration or 0
    e.shake.translation = Vector(0,0)


    world:add(e)
end


local function shelf_action( world, collision, dt)
    local function center( shelf )
        return shelf.sprite.pos + Vector(shelf.collision.width/2, shelf.collision.height) / 2
    end

    local function get_shelf(origin_shelf, tile_rel_coord)


        local dim = Vector(origin_shelf.collision.width, origin_shelf.collision.height)
        local point = center(origin_shelf) + tile_rel_coord:permul(dim)


        local items, num_items = collision:queryPoint(point.x, point.y, function(e) return e.is_shelf == true end)

        if num_items > 0 then
            return items[1]
        end

        return nil
    end


    for i,e in ipairs(world:get("is_shelf")) do
        --push sides over, no delay
        local side1 = e.push_direction:perpendicular():normalize_inplace()
        local side2 = side1 * -1

        if not e.fell_over and e.push_direction:len() > 0 and e.push_delay <= 0 then
            screen_shake(world, 0.1)
            -- visit tiles perpindicular to push direction
            local nodes = {e}
            while #nodes > 0 do
                local s = _.shift(nodes)


                local shelf_side1 = get_shelf(s, side1)
                local shelf_side2 = get_shelf(s, side2)

                if shelf_side1 and not shelf_side1.fell_over then
                    shelf_side1.push_direction = s.push_direction
                    _.push(nodes, shelf_side1)
                end

                if shelf_side2 and not shelf_side2.fell_over then
                    shelf_side2. push_direction = s.push_direction
                    _.push(nodes, shelf_side2) 
                end

                -- touch tiles in push direction and apply push delay and direction

                local shelf_push1 = get_shelf(s, s.push_direction)
                local shelf_push2 = get_shelf(s, s.push_direction * 2)
                if shelf_push1 and not shelf_push1.fell_over then
                    shelf_push1.push_direction = s.push_direction
                    shelf_push1.push_delay = 0.25
                end

                if shelf_push2 and not shelf_push2.fell_over then
                    shelf_push2.push_direction = s.push_direction
                    shelf_push2.push_delay = 0.25
                end



                make_knocked_over_shelf(world, collision, world.tileset, s)
                shelf_fall:play()
                collision:remove(s)
                world:remove(s)
            end

        else 
            e.push_delay = e.push_delay - dt
        end
    end
end



return {
    new = make_shelf,
    update = shelf_action,
    tileset = ShelfTileset,
    make_shelf = make_shelf_piece
}