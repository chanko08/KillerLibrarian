local class =require 'lib/hump/class'
local Level = require 'level'
local InstructionsDialog = require 'instructionsdialog'
local music =  love.audio.newSource("assets/bgmusic2.wav") 
music:setLooping(true)

local MainMenu = class({})

function MainMenu:init()
    self.title_font = love.graphics.newFont('assets/ohwhy.ttf', 48)
    self.font = love.graphics.newFont('assets/ohwhy.ttf', 24)
    self.small = love.graphics.newFont('assets/ohwhy.ttf', 18)
    

   
end

function MainMenu:enter(prev, state)
    music:stop()
    music:play()
    local js = love.joystick.getJoysticks()
    self.gamepad = nil
    if #js > 0 then
        self.gamepad = js[1]
    end

    self.state = state
    self.level = Level()
    self.level:enter(nil, 'assets/lvls/titlescreen.lua')

end

function MainMenu:draw( )
    self.level:draw()

    local w = love.window.getWidth()

    love.graphics.setFont(self.title_font)
    local fh = self.title_font:getHeight()
    
    -- love.graphics.setColor(200, 200, 200)
    -- love.graphics.rectangle('fill', 0, fh, w, fh)

    love.graphics.setColor(255,0,0)
    love.graphics.printf("KILLER      LIBRARIAN", 0, fh, w, "center")

    -- love.graphics.setColor(200, 200, 200)
    -- love.graphics.rectangle('fill', 0, fh*3, w, fh)

    love.graphics.setColor(255,0,0)
    love.graphics.setFont(self.font)
    local f = love.graphics.getFont()
    -- local fh = f:getHeight()
    love.graphics.printf("PRESS ANY KEY OR CONTROLLER BUTTON", 0, 5 + fh*3, w, "center")

    -- love.graphics.setColor(200, 200, 200)
    -- love.graphics.rectangle('fill', 0, fh*5, w, fh)

    love.graphics.setColor(255,0,0)
    love.graphics.setFont(self.small)
    love.graphics.printf("USE WASD OR LEFT CONTROLLER STICK TO MOVE", 0, 15 + fh*5, w, "center")


    love.graphics.setColor(255,0,0)
    love.graphics.setFont(self.small)
    love.graphics.printf("SPACE OR X TO RESTART", 0, 25 + fh*7, w, "center")


    love.graphics.reset()

end

function MainMenu:keypressed( key )
    if key == 'escape' then
        love.event.quit()
        return
    end
    StateMachine.switch(InstructionsDialog())
end

function MainMenu:joystickpressed( js, button )
    StateMachine.switch(InstructionsDialog())
end

function MainMenu:joystickadded( joystick )
    self.gamepad = joystick
end

return MainMenu