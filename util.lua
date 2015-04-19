local Vector = require 'lib/hump/vector'
local function make_position(ind, width, height, tilewidth, tileheight)
    local pos = Vector(math.floor((ind - 1) % width), math.floor((ind - 1) / width))
    pos.x = pos.x * tilewidth
    pos.y = pos.y * tileheight

    return pos
end

return {
    tileIndexToPosition = make_position
}