local class = require 'lib/hump/class'
local inspect = require 'lib/inspect'
local WinGameDialog = class({})

function WinGameDialog:init()
    self.title_font = love.graphics.newFont('assets/ohwhy.ttf', 48)
    self.font = love.graphics.newFont('assets/ohwhy.ttf', 24)
end

function WinGameDialog:enter(prev, state)
    local js = love.joystick.getJoysticks()
    self.gamepad = nil
    if #js > 0 then
        self.gamepad = js[1]
    end

    self.state = state
    self.prev = prev
end

function WinGameDialog:draw( )
    self.prev:draw()

    
    local w = love.window.getWidth()
    local h = love.window.getHeight()
    love.graphics.setFont(self.title_font)
    
    love.graphics.setColor(100, 100, 100, 200)
    love.graphics.rectangle('fill', 0, 0, w, h)
    love.graphics.setColor(200,0,0)
    love.graphics.printf("YOU HAVE BEATEN THE GAME", 0 , self.title_font:getHeight(), w, "center")

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

function WinGameDialog:keypressed( key )
    if key == 'escape' then
        love.event.quit()
    end

    local mainmenu = self.state.valid_states.mainmenu
    self.state.switch(mainmenu(), self.state)
end

function WinGameDialog:joystickpressed( js, button )
    local mainmenu = self.state.valid_states.mainmenu
    -- print('js', inspect(mainmenu))
    self.state.switch(mainmenu(), self.state)
end

function WinGameDialog:joystickadded( joystick )
    self.gamepad = joystick
end

return WinGameDialog