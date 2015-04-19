local class =require 'lib/hump/class'
local Level = require 'level'

local InstructionsDialog = class({})

function InstructionsDialog:init()
    self.title_font = love.graphics.newFont('assets/ohwhy.ttf', 48)
    self.font = love.graphics.newFont('assets/ohwhy.ttf', 24)
    self.small = love.graphics.newFont('assets/ohwhy.ttf', 18)

   
end

function InstructionsDialog:enter(prev)
    local js = love.joystick.getJoysticks()
    self.gamepad = nil
    if #js > 0 then
        self.gamepad = js[1]
    end

    
    self.level = Level()
    self.level:enter(nil, 'assets/lvls/titlescreen.lua')

end

function InstructionsDialog:draw( )
    self.level:draw()

    local w = love.window.getWidth()

    love.graphics.setFont(self.title_font)
    local fh = self.title_font:getHeight()
    
    -- love.graphics.setColor(200, 200, 200)
    -- love.graphics.rectangle('fill', 0, fh, w, fh)

    love.graphics.setColor(255,0,0)
    love.graphics.printf("KNOCK OVER SHELVES TO KILL PEOPLE BY MOVING INTO THE SHELF", 0, fh*4, w, "center")

    -- love.graphics.setColor(200, 200, 200)
    -- love.graphics.rectangle('fill', 0, fh*3, w, fh)

    love.graphics.setColor(255,0,0)
    love.graphics.setFont(self.font)
    local f = love.graphics.getFont()
    -- local fh = f:getHeight()
    love.graphics.printf("PRESS ANY KEY OR CONTROLLER BUTTON", 0, 5 + fh*10, w, "center")
    love.graphics.reset()
end

function InstructionsDialog:keypressed( key )
    if key == 'escape' then
        love.event.quit()
        return
    end
    StateMachine.switch(Level(), 1)
end

function InstructionsDialog:joystickpressed( js, button )
    StateMachine.switch(Level(), 1)
end

function InstructionsDialog:joystickadded( joystick )
    self.gamepad = joystick
end

return InstructionsDialog