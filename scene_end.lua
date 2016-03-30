
local composer = require('composer');

------------------------------------------------------------------

local c             = require('c');
local settings      = require('settings');
local utilities     = require('utilities');
local world_recipes = require('world_recipes');
local collision     = require('collision');
local events        = require('events');
local camera        = require('camera');

------------------------------------------------------------------

local scene = composer.newScene();

------------------------------------------------------------------

function scene:create(event)

    local scene_group = self.view;

    -- Initialize the scene here
    -- Example: add display objects to "scene_group", add touch listeners, etc.

    local text_options = 
    {
        text = "Flua er dau.",     
        x = c.HALF_SCREEN_WIDTH,
        y = c.HALF_SCREEN_HEIGHT,
        width = 512,
        font = 'PTMono-Regular',   
        fontSize = 32,
        align = "center"
    }

    local text = display.newText(text_options);
    text:setFillColor(0);

    scene_group:insert(text);
end

------------------------------------------------------------------

function scene:show(event)

    local scene_group = self.view;
    local phase = event.phase;

    -- Called when the scene is still off screen (but is about to come on screen)

    if (phase == "will") then

        

    -- Called when the scene is now on screen
    -- Insert code here to make the scene come alive
    -- Example: start timers, begin animation, play audio, etc.

    elseif (phase == "did") then
        
        
    end
end

------------------------------------------------------------------

function scene:hide(event)

    local scene_group = self.view;
    local phase = event.phase;

    -- Called when the scene is on screen (but is about to go off screen)
    -- Insert code here to "pause" the scene
    -- Example: stop timers, stop animation, stop audio, etc.

    if (phase == "will") then

        

    -- Called immediately after scene goes off screen

    elseif (phase == "did") then
        
        
    end
end

------------------------------------------------------------------

function scene:destroy(event)

    local scene_group = self.view;

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.

end

------------------------------------------------------------------

scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

------------------------------------------------------------------

return scene;