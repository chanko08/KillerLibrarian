local inspect = require 'lib/inspect'
-- local Level = require 'level'
local Menu = {}

Menu.screens = {}




function Menu.screens.win(gs,continue_func)
    return {
        true,
        gs,
        "YOU WIN",
        200,
        200,
        {
            ["PRESS ANY BUTTON TO CONTINUE"] = continue_func
        },
        "PRESS ANY BUTTON TO CONTINUE"
    }
end

function Menu.screens.win_game(gs)
    return {
        false,
        gs,
        "YOU HAVE BEATEN THE GAME",
        love.window.getWidth(),
        love.window.getHeight(),
        {
            ["PRESS ANY BUTTON TO CONTINUE"] = function()
                local menu = gs.valid_states.menu
                gs.switch(menu, unpack(Menu.screens.start(gs)))
            end
        },
        "PRESS ANY BUTTON TO CONTINUE"
    }
end


function Menu.screens.start(gs)
    return {
        false,
        gs,
        "LIBRARY ASSASSIN",
        love.window.getWidth(),
        love.window.getHeight(),
        {   
            ["START"] = function()
                local level = gs.valid_states.level
                gs.switch(level, gs, 1)
            end,

            ["USE WASD OR XBOX CONTROLLER"] = function ()
                -- body
            end


        },
        "START"

    }
end

function Menu:init()
end


function Menu:enter( prev, draw_prev, state, title, width, height, menu_options, default_option )
    print(inspect(prev))
    self.font = love.graphics.newFont('assets/ohwhy.ttf', 24)
    self.draw_prev = draw_prev
    self.prev = prev
    self.state = state
    self.title = title
    self.width = width
    self.height = height
    
    self.menu_options = menu_options
    
    self.selection = default_option
    
    self.gamepad = nil
    if prev and #self.state.stack > 1 then
        print('prevprint')
        self.gamepad = prev.gamepad
    end
    
end

function Menu:draw( )
    if self.draw_prev and self.prev ~= Menu then
        -- print "FIIIUUUAUSDASDCKCK"
        self.prev:draw()
    end
    love.graphics.setFont(self.font)

    love.graphics.setColor(0,0,0)
    menu_x = (love.window.getWidth() - self.width) / 2
    menu_y = (love.window.getHeight() - self.height) / 2


    love.graphics.rectangle("fill", menu_x, menu_y, self.width, self.height)

    love.graphics.setColor(255,0,0)
    love.graphics.printf(self.title, menu_x, menu_y+5, self.width, "center")

    local f = love.graphics.getFont()
    local i = 1
    for t,funcs in pairs(self.menu_options) do
        love.graphics.printf(t, menu_x, menu_y + i * f:getHeight() + 5, self.width, "center")
        i = i + 1
    end
    love.graphics.reset()

end

function Menu:keypressed( key )
    if key == 'escape' then
        love.event.quit()
    end

    self.menu_options[self.selection]({key=key})
end

function Menu:joystickpressed( js, button )
    self.menu_options[self.selection]({joystick = js, button = button})
end

function Menu:joystickadded( joystick )
    self.gamepad = joystick
end

return Menu