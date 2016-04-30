
local composer = require('composer');

------------------------------------------------------------------

local c             = require('c');
local settings      = require('settings');
local utilities     = require('utilities');
local world_recipes = require('world_recipes');
local collision     = require('collision');
local events        = require('events');
local camera        = require('camera');
local UI            = require('UI');
local objects       = require('objects');
local fly           = require('fly');

------------------------------------------------------------------

local scene = composer.newScene();

------------------------------------------------------------------

local world_name;
local world_recipe;

local storage_object = {};

------------------------------------------------------------------
-- Scene group determines drawing order of groups
-- Camera group determines drawing order of in game objects

local background_group;
local objects_group;
local fly_group;
local camera_group;

local UI_group;

------------------------------------------------------------------

local fly_destination;

------------------------------------------------------------------

local previous_location;
local current_location;
local delta_location;

local location_handler = function(event)

    ------------------------------------------------------------------
    -- Check for error (user may have turned off location services)

    if (event.errorCode) then

        native.showAlert( 'GPS Location Error', event.errorMessage, {'OK'} )
        ----print( 'Location error: ' .. tostring( event.errorMessage ) )

    else

        ------------------------------------------------------------------
        -- Define states

        local latitude = event.latitude;
        local longitude = event.longitude;

        current_location = {};
        current_location.latitude = latitude;
        current_location.longitude = longitude;
        current_location.time = event.time;

        if (previous_location == nil) then

            previous_location = {};
            previous_location.latitude = current_location.latitude;
            previous_location.longitude = current_location.longitude;
            previous_location.time = current_location.time;
        end

        delta_location = {};
        delta_location.latitude = current_location.latitude - previous_location.latitude;
        delta_location.longitude = current_location.longitude - previous_location.longitude;
        delta_location.time = current_location.time - previous_location.time;

        ------------------------------------------------------------------
        -- Check for movement

        local movement_text = 'none';
        local movement = {};

        -- Restrict time between movement, if in car etc.

        if (delta_location.time > settings.LOCATION_TIME_TRESHOLD) then

            -- Euclidean distance from longitude and latitude

            movement.distance  = math.sqrt(delta_location.latitude * delta_location.latitude + delta_location.longitude * delta_location.longitude);
            movement.direction = math.atan2(delta_location.latitude, delta_location.longitude);

            if (movement.distance >= settings.LOCATION_DISTANCE_THRESHOLD) then

                movement_text = 'You\'ve moved';
                movement.valid = true;

                previous_location = {};
                previous_location.latitude = current_location.latitude;
                previous_location.longitude = current_location.longitude;
                previous_location.time = current_location.time;
            end
        end

        ------------------------------------------------------------------
        -- Move world

        if (movement.valid) then
            fly:add_to_destination(settings.LOCATION_STEP_SIZE * math.cos(movement.direction), -settings.LOCATION_STEP_SIZE * math.sin(movement.direction));
        end
    end
end

------------------------------------------------------------------
-- Debug

local DEBUG_INCREMENT = 0.0001;
local debug_iteration = 1;

local debug_event = {};

debug_event.longitude = 0.0001;
debug_event.latitude = 0.0001;
debug_event.time = debug_iteration;

debug_event.altitude = 0;
debug_event.accuracy = 0;
debug_event.speed = 0;
debug_event.direction = 0;

local debug_handler = function()
        
    location_handler(debug_event);

    debug_event.time = debug_iteration;
    debug_iteration = debug_iteration + 1;
end

------------------------------------------------------------------

local debug_with_data_timer;

local debug_handler_data = function()
    
    debug_handler();

    if (debug_iteration % 10 == 0) then

        if (math.random() < 0.5) then
            debug_event.longitude = debug_event.longitude + DEBUG_INCREMENT;
        else
            debug_event.latitude = debug_event.latitude + DEBUG_INCREMENT;
        end
    end
end

------------------------------------------------------------------

local debug_with_event_detector = display.newRect(c.HALF_SCREEN_WIDTH, c.HALF_SCREEN_HEIGHT, c.SCREEN_WIDTH, c.SCREEN_HEIGHT);
debug_with_event_detector.isVisible = false;
debug_with_event_detector.isHitTestable = true;

local debug_handler_event = function(event)
    
    debug_handler();

    local delta_x = event.x - c.HALF_SCREEN_WIDTH;
    local delta_y = event.y - c.HALF_SCREEN_HEIGHT;

    local alpha = math.atan2(delta_y, delta_x);
    local magnitude = delta_x * delta_x + delta_y * delta_y;

    debug_event.longitude = debug_event.longitude + 0.1 * magnitude * math.cos(alpha);
    debug_event.latitude = debug_event.latitude - 0.1 * magnitude * math.sin(alpha);
end

------------------------------------------------------------------

local addLocationListener = function()

    if (settings.DEBUG) then

        if (settings.DEBUG_MODE == c.DEBUG_WITH_EVENT) then
            debug_with_event_detector:addEventListener('tap', debug_handler_event);
        else
            debug_with_data_timer = timer.performWithDelay(50, debug_handler_data, -1);
        end
    else
        Runtime:addEventListener('location', location_handler);
    end
end

local removeLocationListener = function()

    if (settings.DEBUG) then

        if (settings.DEBUG_MODE == c.DEBUG_WITH_EVENT) then
            debug_with_event_detector:removeEventListener('tap', debug_handler_event);
        else
            timer.cancel(debug_with_data_timer);
        end
    else
        Runtime:removeEventListener('location', location_handler);
    end
end

------------------------------------------------------------------

local game_loop = {};

function game_loop:enterFrame(event)

    if (not storage_object.changing_scene) then

        local timed_out = UI:update_clock();
        
        ------------------------------------------------------------------

        objects:update();
        fly:update(world_recipe.frame);
        
        local camera_offset = camera:update(camera_group, fly:get_position(), world_recipe.frame);

        objects:simulate_perspective(camera_offset);
        objects:check_collisions(fly:get_object());

        ------------------------------------------------------------------

        if (timed_out) then
            
            Runtime:removeEventListener('enterFrame', game_loop);
            Runtime:removeEventListener('heading', game_loop);

            storage_object.changing_scene = true;
            composer.gotoScene('scene_death');

        elseif (storage_object.portal_activated) then
            
            local goto_options = {
                params  = 
                {
                    world_name = storage_object.portal_world_name
                }
            }

            Runtime:removeEventListener('enterFrame', game_loop);
            Runtime:removeEventListener('heading', game_loop);

            storage_object.changing_scene = true;
            composer.gotoScene('scene_world', goto_options);

            storage_object.portal_activated = nil;
            storage_object.portal_world_name      = nil;
        end
    end
end

function game_loop:heading(event)
    UI.compass.rotation = event.magnetic;
end

------------------------------------------------------------------

function scene:create(event)

    local scene_group = self.view;

    ------------------------------------------------------------------

    world_name = event.params.world_name;
    world_recipe = world_recipes:get(world_name);

    storage_object = {};

    ------------------------------------------------------------------

    objects:reset();

    ------------------------------------------------------------------

    background_group    = display.newGroup();
    objects_group       = display.newGroup();
    fly_group           = display.newGroup();
    front_objects_group = display.newGroup();
    camera_group        = display.newGroup();

    UI_group            = display.newGroup();

    camera_group:insert(background_group);
    camera_group:insert(objects_group);
    camera_group:insert(fly_group);
    camera_group:insert(front_objects_group);

    scene_group:insert(camera_group);
    scene_group:insert(UI_group);

    ------------------------------------------------------------------

    UI:construct_backgrounds();

    UI:construct_clock();
    UI:update_clock();

    UI:construct_happy_meter();
    UI:construct_compass();

    UI:construct_message_box(world_recipe.messages);

    UI.message_background:addEventListener('tap', UI.message_event);

    ------------------------------------------------------------------

    UI_group:insert(UI.background_left);
    UI_group:insert(UI.background_right);
    UI_group:insert(UI.clock);
    UI_group:insert(UI.happy_meter_background);
    UI_group:insert(UI.happy_meter);
    UI_group:insert(UI.compass);
    UI_group:insert(UI.message_background);
    UI_group:insert(UI.message_text);

    ------------------------------------------------------------------

    objects:construct(world_recipe, objects_group, storage_object, front_objects_group);
    objects:link();

    ------------------------------------------------------------------

    fly:construct(world_recipe, fly_group);

    ------------------------------------------------------------------

    camera:initialize(world_recipe);
end

------------------------------------------------------------------

function scene:show(event)

    local scene_group = self.view;
    local phase = event.phase;

    -- Called when the scene is still off screen (but is about to come on screen)

    if (phase == 'will') then

        camera:update(camera_group, fly:get_position(), world_recipe.frame);

    -- Called when the scene is now on screen
    -- Insert code here to make the scene come alive
    -- Example: start timers, begin animation, play audio, etc.

    elseif (phase == 'did') then
        
        addLocationListener();

        Runtime:addEventListener('enterFrame', game_loop);
        Runtime:addEventListener('heading', game_loop);
    end
end

------------------------------------------------------------------

function scene:hide(event)

    local scene_group = self.view;
    local phase = event.phase;

    -- Called when the scene is on screen (but is about to go off screen)
    -- Insert code here to "pause" the scene
    -- Example: stop timers, stop animation, stop audio, etc.

    if (phase == 'will') then

        removeLocationListener();

    -- Called immediately after scene goes off screen

    elseif (phase == 'did') then
        
        composer.removeScene('scene_world');
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