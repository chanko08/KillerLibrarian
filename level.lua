local inspect = require 'lib/inspect'
local _       = require 'lib/underscore'
local Vector  = require 'lib/hump/vector'
local Bump    = require 'lib/bump'
local class   = require 'lib/hump/class'

local World   = require 'world'
local Shelf   = require 'shelf'
local Patron  = require 'patron'
local Computer = require 'computer'
local Settings = require 'settings'

local Menu = require 'menu'

local WinLevelDialog = require 'winleveldialog'
local WinGameDialog  = require 'wingamedialog'

local Level = class({})
Level.levels = {
    'assets/lvls/level01.lua',
    'assets/lvls/level10.lua',
    'assets/lvls/level11.lua',
    'assets/lvls/level02.lua',
    'assets/lvls/level03.lua',
    'assets/lvls/level04.lua',
    'assets/lvls/level05.lua',
    'assets/lvls/level06.lua',
    'assets/lvls/level09.lua',
    'assets/lvls/level07.lua',
    'assets/lvls/level12.lua',
    'assets/lvls/level08.lua'
}

-- TODO: make it so tilesets account for spacing and margin properties
local function load_tilesets( tileset_data )
    table.sort(tileset_data, function(d1,d2) return d1.firstgid < d2.firstgid end)
    local tileset = {}

    for i,tset in ipairs(tileset_data) do
        --local tileset = {}
        local image = love.graphics.newImage(Settings.LEVELS_FOLDER .. tset.image)

        


        local numtilerows = math.floor(tset.imagewidth / tset.tilewidth)
        local numtilecols = math.floor(tset.imageheight / tset.tileheight)

        for row=0,numtilerows-1 do
            for col=0,numtilecols-1 do
                
                local x = row * tset.tilewidth
                local y = col * tset.tileheight

                local tile = {}
                tile.quad = love.graphics.newQuad(x, y, tset.tilewidth, tset.tileheight, tset.imagewidth, tset.imageheight)
                tile.image = image
                tile.width = tset.tilewidth
                tile.height = tset.tileheight
                tile.local_id  = col * numtilecols + row
                tile.global_id = tile.local_id + tset.firstgid 
                tile.tileset_name = tset.name
                

                table.insert(tileset, tile)
            end
        end
    end
    table.sort(tileset, function(t1, t2) return t1.global_id < t2.global_id end)
    return tileset
end

local function load_level(level_data)
    local tileset = load_tilesets(level_data.tilesets)

    local world = World()
    for i, layer in ipairs(level_data.layers) do
        -- if layer.name == 'foreground' or layer.name == 'Tile Layer 1' then
        if layer.type == 'tilelayer' then
            world:load(tileset, layer)
        end
    end

    --print(inspect(entities, {depth=3}))
    return world
end






function Level:init()
    self.level_index = 1
    self.world = nil
    local js = love.joystick.getJoysticks()
    self.gamepad = js[1]
    self.collision = Bump.newWorld(32)
    self.state = nil
    self.win = false
    self.win_delay = 2
    self:reset()
    self.win_music = love.audio.newSource('assets/level_win.wav',"static")
    self.win_game_music = love.audio.newSource('assets/game_win.wav',"static")
end

function Level:reset()
    self.level_index = 1
    self.world = nil
    local js = love.joystick.getJoysticks()
    self.gamepad = js[1]
    self.collision = Bump.newWorld(32)
    self.state = nil
end

function Level:enter(old, level)
    self:reset()

    self.state = StateMachine

    if Level.levels[level] then
        self.level_index = level
        self.level = Level.levels[level]
    else
        self.level_index = 0
        self.level = level
    end
    -- body
    print(self.level, level)
    local ok, level = pcall(love.filesystem.load, self.level)
    if ok then
        local level_data = level()
        self.world = load_level(level_data)
    else
        error("DATA WASNT LOADEDDD")
    end

    for i,e in ipairs(self.world:get("collision", "sprite")) do
        local cpos = e.sprite.pos + e.collision.offset

        self.collision:add(
            e,
            cpos.x,
            cpos.y,
            e.collision.width,
            e.collision.height
        )
    end

    --now add a wall around outside of image
    e = {side='left'}
    self.collision:add(
        e,
        -32,
        0,
        32,
        love.window.getHeight()
    )

    e = {side='right'}
    self.collision:add(
        e,
        love.window.getWidth(),
        0,
        32,
        love.window.getHeight()
    )


    e = {side='top'}
    self.collision:add(
        e,
        0,
        -32,
        love.window.getWidth(),
        32
    )    

    e = {side='top'}
    self.collision:add(
        e,
        0,
        love.window.getHeight(),
        love.window.getWidth(),
        32
    )    
end


local function draw_sprite( sprite )
    love.graphics.draw(
        sprite.tile.image,
        sprite.tile.quad,
        sprite.pos.x,
        sprite.pos.y
    )
end

function Level:draw()
    love.graphics.setBackgroundColor(255,255,255)
    love.graphics.clear()
    -- body
    love.graphics.push()
    local t = Vector(0,0)
    local n = 0
    for i,e in ipairs(self.world:get('shake')) do
        t = t + e.shake.translation
        n = n + 1
    end
    if n > 0 then
        t = t / n
    end

    love.graphics.translate(t.x * 20, t.y * 20)
    

    local function zordering( e1, e2 )
        return e1.sprite.z < e2.sprite.z 
    end

    local ents = self.world:get("sprite")
    table.sort(ents, zordering)
    for i,e in ipairs(ents) do
        draw_sprite(e.sprite)
    end

    
    -- for i,e in ipairs(self.world:get("sprite", "collision")) do
    --     if e.is_shelf and e.fell_over then
    --         love.graphics.setColor(0, 255, 0)
    --     else
    --         love.graphics.setColor(255, 0, 0)
    --     end

        
    --     love.graphics.rectangle(
    --         'line',
    --         e.sprite.pos.x + e.collision.offset.x,
    --         e.sprite.pos.y + e.collision.offset.y,
    --         e.collision.width,
    --         e.collision.height
    --     )
    -- end
    love.graphics.pop()
    love.graphics.reset()
end

function Level:update( dt )
    -- body
    if self.gamepad then
        for i,e in ipairs(self.world:get("is_player", "move")) do
            local xaxis, yaxis = self.gamepad:getAxes()

            if xaxis < Settings.GAMEPAD_DEADZONE and xaxis > -Settings.GAMEPAD_DEADZONE then
                xaxis = 0
            end

            if yaxis < Settings.GAMEPAD_DEADZONE and yaxis > -Settings.GAMEPAD_DEADZONE then
                yaxis = 0
            end

            e.move.vel.x = xaxis * e.move.max_speed
            e.move.vel.y = yaxis * e.move.max_speed
        end
    else
        for i,e in ipairs(self.world:get("is_player", "move")) do
            if love.keyboard.isDown('w') then
                e.move.vel.y = -1 * e.move.max_speed
            elseif love.keyboard.isDown('s') then

                e.move.vel.y = e.move.max_speed
            else 
                e.move.vel.y = 0
            end

            if love.keyboard.isDown('a') then
                e.move.vel.x = -1 * e.move.max_speed
            elseif love.keyboard.isDown('d') then
                e.move.vel.x = e.move.max_speed
            else
                e.move.vel.x = 0
            end
        end
    end

    for i,e in ipairs(self.world:get("sprite", "collision", "move")) do
        local next_pos = e.sprite.pos + e.move.vel * dt
        local cpos = next_pos + e.collision.offset
        local actual_x, actual_y, collisions, len = self.collision:move(e, cpos.x, cpos.y)

        e.sprite.pos = Vector(actual_x, actual_y) - e.collision.offset

        for i,collision in ipairs(collisions) do
            -- print('colliding with...')
            -- print(inspect(collision.other, {depth=1}))
            -- print(inspect(collision.other.sprite, {depth=1}))

            local other = collision.other
            if other.is_shelf and not other.fell_over and e.is_player then
                local normal = collision.normal
                other.push_direction = Vector(normal.x, normal.y) * -1
            end
        end
    end


    Shelf.update(self.world, self.collision, dt)
    Patron.update(self.world, self.collision, dt)
    Computer.update(self.world, self.collision, dt)

    for i,e in ipairs(self.world:get("sprite", "animation")) do
        if not e.animation.done then
            e.animation.time = e.animation.time + dt
            e.animation.full_time = e.animation.full_time + dt

            if e.animation.time >= e.animation.delay then
                e.animation.frame = e.animation.frame + 1
                if e.animation.frame > #e.animation.tiles then
                    e.animation.frame = 1
                end

                e.sprite.tile = e.animation.tiles[e.animation.frame]
                e.animation.time = 0
            end

            if e.animation.full_time >= e.animation.duration then
                e.animation.done = true
            end
        end
    end

    for i,e in ipairs(self.world:get("animation", "is_explosion", "sprite")) do
        if e.animation.done then
            self.world:remove(e)
            self.collision:remove(e)
        end


        --do check to see if there are things on the tile the explosion is on
        local dim = Vector(e.sprite.tile.width, e.sprite.tile.height)
        local c = e.sprite.pos + dim / 2

        local items, len = self.collision:queryPoint(c:unpack())

        for i, item in ipairs(items) do
            if item.is_shelf then
                item.push_direction = e.push_direction
            elseif item.is_computer then
                item.explode = true
            end
        end
    end

    for i,e in ipairs(self.world:get('shake')) do
        if e.shake.time >= e.shake.duration then
            self.world:remove(e)
        else
            local x = math.random() - 0.5 
            local y = math.random() - 0.5
            e.shake.translation = Vector(x, y)
            e.shake.time = e.shake.time + dt
        end
    end

    if #self.world:get("is_patron") == 0 then
        self.win = true

        
    end

    if self.win and self.win_delay <= 0 then
        local menu_state = self.state.valid_states.menu

        if self.level_index < #Level.levels then

            local winlevel = self.state.valid_states.winleveldialog
            self.win_music:play()
            self.state.switch(winlevel(), self.state)
        else
            local wingame = self.state.valid_states.wingamedialog
            self.win_game_music:play()
            self.state.switch(wingame(), self.state)
        end
    elseif self.win then
        self.win_delay = self.win_delay - dt
    end

end

function Level:keypressed( key )
    if key == 'escape' then
        love.event.quit()
    elseif key == ' ' then
        if self.level_index > 0 then
            self.state.switch(self.state.valid_states.level(),  self.level_index)
        else
            self.state.switch(self.state.valid_states.level(),  self.level)
        end
    end
end

function Level:joystickpressed(joystick, button)
    if joystick:isGamepadDown('x') then
        self.state.switch(self.state.valid_states.level() , self.level_index)
    end
end

function Level:joystickadded( joystick )
    self.gamepad = joystick
end


return Level
