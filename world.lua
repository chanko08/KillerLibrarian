local class  = require 'lib/hump/class'
local Vector = require 'lib/hump/vector'
local _ = require 'lib/underscore'
local inspect = require 'lib/inspect'
local util = require 'util'

local Shelf = require 'shelf'
local Patron = require 'patron'
local Computer = require 'computer'
local Player = require 'player'

local Component = require 'component'

local Settings = require 'settings'

local LevelObjectsTileset    = {}
LevelObjectsTileset.shelf    = 1
LevelObjectsTileset.computer = 2
LevelObjectsTileset.patron   = 3
LevelObjectsTileset.player   = 4
LevelObjectsTileset.ground   = 15
LevelObjectsTileset.shelf_fall_left = 31
LevelObjectsTileset.shelf_fall_horizontal_center = 32
LevelObjectsTileset.shelf_fall_right = 33






local function make_position(ind, width, height, tilewidth, tileheight)
    local pos = Vector(math.floor(ind % width), math.floor(ind / height))
    pos.x = pos.x * tilewidth
    pos.y = pos.y * tileheight

    return pos
end



local World = class({})

function World:init()
    self.all = {}
    self.component = {}

    self.tileset = nil
end

function World:get( ... )
    local component_names = {...}
    if #component_names == 0 then return {} end


    local ents = _.keys(self.component[component_names[#component_names]] or {})

    local function check_component(ents, comp)
        return _.select(ents, function(e) return (self.component[comp] or {})[e] == true end)
    end

    ents = _.foldl(component_names, ents, check_component)

    return ents
end

function World:add( entity )
    self.all[entity] = true

    for component_name, component in pairs(entity) do
        if not self.component[component_name] then
            self.component[component_name] = {}
        end
        self.component[component_name][entity] = true
    end
end


function World:remove( entity )
    self.all[entity] = nil
    for component_name, component in pairs(entity) do
        if not self.component[component_name] then
            self.component[component_name] = {}
        end
        self.component[component_name][entity] = nil
    end
end

function World:load( tileset, layer_data )
    self.tileset = tileset

    for i, obj_type in ipairs(layer_data.data) do
        local w = layer_data.width
        local h = layer_data.height

        if obj_type == LevelObjectsTileset.shelf then
            local shelf = Shelf.new(tileset, i, w, h)
            self:add(shelf)
        elseif obj_type == LevelObjectsTileset.computer then
            local computer = Computer.new(tileset, i, w, h)
            self:add(computer)

        elseif obj_type == LevelObjectsTileset.patron then
            local patron = Patron.new(tileset, i, w, h)
            self:add(patron)

        elseif obj_type == LevelObjectsTileset.player then
            
            local player = Player.new(tileset, i, w, h)
            self:add(player)
        elseif obj_type == LevelObjectsTileset.ground then
            local ground = {}
            ground.sprite ={}
            ground.sprite = Component.sprite(tileset, LevelObjectsTileset.ground, i, w, h)
            ground.sprite.z = -10
            self:add(ground)
        
        elseif obj_type == LevelObjectsTileset.shelf_fall_left then
            local shelf_piece = Shelf.make_shelf(tileset, {31, 0, 16, 0, 16, 32}, w, h, i)
            self:add(shelf_piece)


        elseif obj_type == LevelObjectsTileset.shelf_fall_horizontal_center then
            local shelf_piece = Shelf.make_shelf(tileset, {32, 1,  0, 0, 32, 32}, w, h, i)
            self:add(shelf_piece)


        elseif obj_type == LevelObjectsTileset.shelf_fall_right then
            local shelf_piece = Shelf.make_shelf(tileset, {33, 1,  0, 0, 16, 32}, w, h, i)
            self:add(shelf_piece)


        end

    end
end

return World