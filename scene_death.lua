
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

local video;

local remembered_scene_event;

------------------------------------------------------------------

function scene:create(event)

    local scene_group = self.view;

    display.setDefault('background', 0, 0, 0);

    ------------------------------------------------------------------

    -- These values are madness, but seam to work.
    video = native.newVideo( display.contentCenterX, display.contentCenterY*2, math.floor(display.contentWidth*9/16)*2, display.contentWidth*2 )

    local function videoListener( event )
        print( "Event phase: " .. event.phase )

        if event.phase == 'ended' then

            video:pause()
            video:removeSelf()
            video = nil

            display.setDefault('background', 1, 1, 1);
            local curtain = display.newRect(0, 0, 4000, 4000);
            curtain:setFillColor(0,0,0)

            composer.gotoScene('scene_end', remembered_scene_event);
        end

        if event.errorCode then
            native.showAlert( "Error!", event.errorMessage, { "OK" } )
        end
    end
    


    -- Load a video
    video:load(settings.VIDEO_FOLDER .. "slutt.mp4", system.DocumentsDirectory )

    -- Add video event listener 
    video:addEventListener( "video", videoListener )


    --local happy_meter = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_happy_meter_2.png', 76, 76);
    --happy_meter.x = c.HALF_SCREEN_WIDTH;
    --happy_meter.y = 600;

    ------------------------------------------------------------------

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

    --local text = display.newText(text_options);
    --text:setFillColor(0);

    ------------------------------------------------------------------

    --scene_group:insert(happy_meter);   
    --scene_group:insert(text);
end

------------------------------------------------------------------

function scene:show(event)

    local scene_group = self.view;
    local phase = event.phase;

    remembered_scene_event = event;

    -- Called when the scene is still off screen (but is about to come on screen)

    if (phase == "will") then

        if system.getInfo("environment") == "simulator" then
            
            display.setDefault('background', 1, 1, 1);
            --local curtain = display.newRect(0, 0, 4000, 4000);
            --curtain:setFillColor(0,0,0)

            composer.gotoScene('scene_end', event);
        else
            video:play()
        end

        --composer.gotoScene('scene_world', event);
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