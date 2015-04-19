local inspect = require 'lib/inspect'
local _ = require 'lib/underscore'
local Level = require 'level'
local Menu = require 'menu'
local MainMenu = require 'mainmenu'
local WinLevelDialog = require 'winleveldialog'
local WinGameDialog = require 'wingamedialog'
local InstructionsDialog = require 'instructionsdialog'




StateMachine = {}
StateMachine.valid_states = {
    menu=Menu,
    level=Level,
    mainmenu = MainMenu,
    winleveldialog = WinLevelDialog,
    wingamedialog = WinGameDialog,
    instructionsdialog = InstructionsDialog
}

StateMachine.keys = {}

StateMachine.current = nil

function StateMachine.switch( state, ... )
    StateMachine.next_state = state
    StateMachine.args = {...}
end

function love.load( args )
    print(inspect(args))
    if args[2] then
        local l = Level(args[2])
        StateMachine.current = l
        StateMachine.switch(Level(), args[2])

    else
        StateMachine.current = MainMenu()
        StateMachine.switch(MainMenu())
    end

    

    --GS.registerEvents()
    --GS.switch(MainMenu(), GS)
end


function love.draw( ... )
    if StateMachine.current.draw then
        StateMachine.current:draw(...)
    end
end

function love.update( ... )
    if StateMachine.next_state then
        if StateMachine.current.leave then
            StateMachine.current:leave()
        end

        local old = StateMachine.current
        StateMachine.current = StateMachine.next_state

        if StateMachine.current.enter then
            StateMachine.current:enter(old, unpack(StateMachine.args))
        end

        StateMachine.next_state = nil
        StateMachine.args = nil
    end


    if StateMachine.current.update then
        StateMachine.current:update(...)
    end

    if StateMachine.current.keypressed then
        for i, kev in ipairs(StateMachine.keys) do
            StateMachine.current:keypressed(unpack(kev))
        end
    end

    StateMachine.keys = {}

end

function love.keypressed( ... )
    local kev = {...}
    _.push(StateMachine.keys, kev)
    -- if StateMachine.current.keypressed then
    --     StateMachine.current:keypressed(...)
    -- end
end


function love.joystickadded( ... )
    if StateMachine.current.joystickadded then
        StateMachine.current:joystickadded(...)
    end
end

function love.joystickpressed( ... )
    if StateMachine.current.joystickpressed then
        StateMachine.current:joystickpressed(...)
    end
end