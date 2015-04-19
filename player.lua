local Component = require 'component'
local inspect = require 'lib/inspect'
local _ = require 'lib/underscore'
local Vector = require 'lib/hump/vector'
local Settings = require 'settings'

local PlayerTileset = {}
PlayerTileset.default = 4

local function make_player( tileset, index, level_width, level_height )
    local player = {}

    player.sprite = Component.sprite(
        tileset,
        PlayerTileset.default,
        index,
        level_width,
        level_height
    )
    player.sprite.z = 10
    player.collision = Component.collision(
        player.sprite.tile.width - 6,
        player.sprite.tile.height - 6,
        Vector(3,3)
    )
    
    player.is_player = true

    player.move = {}
    player.move.vel = Vector(0,0)
    player.move.max_speed =  Settings.movement.MAX_SPEED
    return player
end

return {
    new = make_player
}