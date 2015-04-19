local class = require 'lib/hump/class'

local WinLevelDialog = class({})

function WinLevelDialog:init()
    self.title_font = love.graphics.newFont('assets/ohwhy.ttf', 48)
    self.font = love.graphics.newFont('assets/ohwhy.ttf', 24)
end

function WinLevelDialog:enter(prev)
    local js = love.joystick.getJoysticks()
    self.gamepad = nil
    if #js > 0 then
        self.gamepad = js[1]
    end

    self.state = StateMachine
    self.prev = prev
end

function WinLevelDialog:draw( )
    self.prev:draw()

    local w = love.window.getWidth()
    local h = love.window.getHeight()
    love.graphics.setFont(self.title_font)
    
    love.graphics.setColor(100, 100, 100, 200)
    love.graphics.rectangle('fill', 0, 0, w, h)
    love.graphics.setColor(200,0,0)
    love.graphics.printf("YOU WIN", 0 , self.title_font:getHeight(), w, "center")

    love.graphics.setFont(self.font)
    local f = love.graphics.getFont()
    love.graphics.printf(
        "PRESS ANY KEY OR CONTROLLER BUTTON",
        0,
        5 + self.title_font:getHeight()*3,
        w,
        "center"
    )
    love.graphics.reset()

end

function WinLevelDialog:keypressed( key )
    if key == 'escape' then
        love.event.quit()
    end

    self.state.switch(self.state.valid_states.level(), self.prev.level_index + 1)
end

function WinLevelDialog:joystickpressed( js, button )
   self.state.switch(self.state.valid_states.level(), self.prev.level_index + 1)
end

function WinLevelDialog:joystickadded( joystick )
    self.gamepad = joystick
end

return WinLevelDialog