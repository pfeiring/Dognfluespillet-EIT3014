
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
-- Forward references

local world_name;
local world_recipe;

------------------------------------------------------------------

local changing_scene = false;

------------------------------------------------------------------
-- Scene group determines drawing order of groups
-- Camera group determines drawing order of in game objects

local background_group;
local objects_group;
local fly_group;
local camera_group;

local UI_group;

------------------------------------------------------------------

local UI;
local objects;

local fly;
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

            fly_destination.x = fly.x + settings.LOCATION_STEP_SIZE * math.cos(movement.direction);
            fly_destination.y = fly.y - settings.LOCATION_STEP_SIZE * math.sin(movement.direction);
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

local fly_update = function()
    
    local delta_x = fly_destination.x - fly.x;
    local delta_y = fly_destination.y - fly.y;
    
    local alpha = math.atan2(-delta_y, delta_x);

    local delta_speed = (delta_x * delta_x) + (delta_y * delta_y);

    local step_x;
    local step_y;

    if (delta_speed < (settings.FLY_SPEED * settings.FLY_SPEED)) then
        step_x = math.sqrt(delta_speed) * math.cos(alpha);
        step_y = math.sqrt(delta_speed) * math.sin(alpha);
    else
        step_x = settings.FLY_SPEED * math.cos(alpha);
        step_y = settings.FLY_SPEED * math.sin(alpha);
    end

    fly.x = fly.x + step_x;
    fly.y = fly.y - step_y;

    if (step_x > 0.01 * settings.FLY_SPEED) then
        fly.xScale = -0.4;
    elseif (step_x < -0.01 * settings.FLY_SPEED) then
        fly.xScale = 0.4;
    end

    local offset = camera:update(camera_group, fly, world_recipe.frame, world_recipe.objects);
    
    -- Adjust position of objects that simulate perspective offset

    for i = 1, #objects do

        local object = objects[i];
        
        if (object.perspective_factor) then
            
            transition.to( object, {time=0, x = - (offset.x * object.perspective_factor), y = - (offset.y * object.perspective_factor)})
        end
    end

    -- Collision checks

    for i = 1, #objects do

        local object = objects[i];
        
        if (object.body == c.MESSAGE and not object.taken and collision:box(fly, object)) then
            
            object.taken = true;
            UI.message:show(object.message_index);

        elseif (object.body == c.TREASURE and not object.taken and collision:box(fly, object)) then

            object.taken = true;
            object.isVisible = false;

            UI.happy_meter:update(object.happy_meter_gain);
        end
    end
end

------------------------------------------------------------------

local game_loop = {};

function game_loop:enterFrame(event)

    if (not changing_scene) then

        timed_out = UI.clock:update();
        fly_update();

        if (timed_out) then
            
            Runtime:removeEventListener('enterFrame', game_loop);
            Runtime:removeEventListener('heading', game_loop);

            changing_scene = true;
            composer.gotoScene('scene_end');
        end
    end
end

function game_loop:heading(event)
    UI.compass.rotation = event.magnetic;
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

function scene:create(event)

    local scene_group = self.view;

    -- Initialize the scene here
    -- Example: add display objects to "scene_group", add touch listeners, etc.

    ------------------------------------------------------------------

    world_name = event.params.world_name;
    world_recipe = world_recipes:get(world_name);

    ------------------------------------------------------------------

    changing_scene = false;

    ------------------------------------------------------------------
    -- Group setup

    background_group = display.newGroup();
    objects_group = display.newGroup();
    fly_group = display.newGroup();
    camera_group = display.newGroup();

    UI_group = display.newGroup();

    camera_group:insert(background_group);
    camera_group:insert(objects_group);
    camera_group:insert(fly_group);

    scene_group:insert(camera_group);
    scene_group:insert(UI_group);

    ------------------------------------------------------------------

    UI = {};

    ------------------------------------------------------------------

    UI.background_left = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_background.png', 176, 176);
    UI.background_left.x = (176 / 2);
    UI.background_left.y = (176 / 2);

    UI.background_right = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_background.png', 176, 176);
    UI.background_right.x = c.SCREEN_WIDTH - (176 / 2);
    UI.background_right.y = (176 / 2);

    ------------------------------------------------------------------

    UI.clock = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_clock.png', 176, 176);
    UI.clock.x = UI.background_left.x;
    UI.clock.y = UI.background_left.y;
    UI.clock.yScale = 1;
    UI.clock.start_time = os.time();

    function UI.clock:update(self)

        local current_time = os.time();
        local elapsed_time = current_time - UI.clock.start_time;
        
        local timed_out;

        if (elapsed_time >= (settings.GAME_DURATION_IN_MINUTES * 60)) then
            UI.clock.rotation = 360;
            UI.clock.isVisible = false;

            timed_out = true;
        else
            UI.clock.rotation = 360 * (elapsed_time / (settings.GAME_DURATION_IN_MINUTES * 60));

            timed_out = false;
        end

        return timed_out;
    end

    ------------------------------------------------------------------

    UI.happy_meter_background = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_happy_meter_background.png', 176, 176);
    UI.happy_meter_background.x = UI.background_left.x;
    UI.happy_meter_background.y = UI.background_left.y;

    ------------------------------------------------------------------

    UI.happy_meter = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_happy_meter_2.png', 76, 76);
    UI.happy_meter.x = UI.background_left.x;
    UI.happy_meter.y = UI.background_left.y;
    UI.happy_meter.value = settings.HAPPY_METER_START_SCALE;

    UI.happy_meter_mask = graphics.newMask(settings.IMAGE_FOLDER .. 'UI_happy_meter_mask.png');
    UI.happy_meter:setMask(UI.happy_meter_mask);

    UI.happy_meter.maskY = 76 * (1 - UI.happy_meter.value);

    function UI.happy_meter:update(increase)

        UI.happy_meter.value = math.min(1, UI.happy_meter.value + increase);
        UI.happy_meter.maskY = 76 * (1 - UI.happy_meter.value);
    end

    ------------------------------------------------------------------

    UI.message = {};
    UI.message.index = -1;
    UI.message.entry = -1;

    UI.message_background = display.newImageRect(settings.IMAGE_FOLDER .. 'message_background.png', 640, 640);
    UI.message_background.x = c.HALF_SCREEN_WIDTH;
    UI.message_background.y = c.HALF_SCREEN_HEIGHT + 350;
    UI.message_background.isVisible = false;

    UI.message_text = display.newText({
            text = '',
            x = UI.message_background.x,
            y = UI.message_background.y + 10,
            width = 540,
            font = 'PTMono-Regular',
            fontSize = 32,
            align = 'center'});
    UI.message_text:setFillColor(0);
    UI.message_text.isVisible = false;

    function UI.message:event(event)

        UI.message.entry = UI.message.entry + 1;

        if (#world_recipe.messages[UI.message.index] >= UI.message.entry) then

            local message = world_recipe.messages[UI.message.index];
            local message_text = message[UI.message.entry];

            UI.message_text.text = message_text;
        else
            UI.message.index = -1;
            UI.message.entry = -1;

            UI.message_background.isVisible = false;
            UI.message_text.isVisible = false;
        end

        return true;
    end

    function UI.message:show(message_index)

        UI.message.index = message_index;
        UI.message.entry = 1;

        local message = world_recipe.messages[UI.message.index];
        local message_text = message[UI.message.entry];

        UI.message_text.text = message_text;

        UI.message_background.isVisible = true;
        UI.message_text.isVisible = true;
    end

    UI.message_background:addEventListener('tap', UI.message.event);

    ------------------------------------------------------------------

    UI.compass = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_compass.png', 176, 176);
    UI.compass.x = UI.background_right.x;
    UI.compass.y = UI.background_right.y;

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
    
    objects = {};

    for i = 1, #world_recipe.objects do
    
        local recipe = world_recipe.objects[i];
        local object;

        -- Asset

        if (recipe.rectangle) then
            object = display.newRect(0, 0, recipe.width, recipe.height);
        else
            object = display.newImageRect(settings.IMAGE_FOLDER .. recipe.file, recipe.width, recipe.height);
        end

        if (recipe.invisible) then
            object.isVisible = false;
        end

        if (recipe.fill_color) then
            object:setFillColor(unpack(recipe.fill_color));
        end

        object.alpha = utilities:conditioned_value_or_default(recipe.alpha, recipe.alpha, 1);
        
        -- Object

        object.x = recipe.x;
        object.y = recipe.y;
        
        object.id = recipe.id;
        object.link = recipe.link;

        object.body = recipe.body;
        object.direction = recipe.direction;
        object.perspective_factor = recipe.perspective_factor;

        objects[#objects + 1] = object;
        objects_group:insert(object);

        -- Collision

        if (recipe.body) then

            local body = recipe.body;

            if (body == c.MESSAGE) then
                
                object.message_index = recipe.message_index;

            elseif (body == c.TREASURE) then

                object.happy_meter_gain = recipe.happy_meter_gain;
            end
        end

        -- Events

        if (recipe.event) then
            
            local event = recipe.event;
            
            if (event.type == c.BALLOON) then

                object.happy_meter = UI.happy_meter;

                object.offset = {};
                object.offset.x = event.offset.x;
                object.offset.y = event.offset.y;
                
                object:addEventListener('tap', events.balloon_event);

            elseif (event.type == c.WAVE) then

                object.happy_meter = UI.happy_meter;

                object:addEventListener('tap', events.wave_event);

            elseif (event.type == c.ACTIVATOR) then

                object.happy_meter = UI.happy_meter;
                
                object.isHitTestable = true;
                object:addEventListener('tap', events.activator_event);
            end
        end
    end

    ------------------------------------------------------------------
    -- Setup links between objects

    for i = 1, #objects do

        local object = objects[i];
        
        if (object.link) then

            for j = 1, #objects do

                local target = objects[j];
                
                if (target.id and target.id == object.link) then
                    
                    object.link = target;
                end
            end
        end
    end

    ------------------------------------------------------------------

    local sheetOptions = 
    {
        width = 657,
        height = 626,
        numFrames = 9,
        sheetContentWidth = 5921,
        sheetContentHeight = 626
    }
    
    local sheet_flyingFly = graphics.newImageSheet(settings.IMAGE_FOLDER .. 'sprite_fly.png', sheetOptions )
    
    local sequences_flyingFly = {
        -- consecutive frames sequence
        {
            name = 'normalFlying',
            start = 1,
            count = 9,
            time = 1000,
            loopCount = 0,
            loopDirection = 'forward'
        }
    }    

    fly = display.newSprite( sheet_flyingFly, sequences_flyingFly )

    --fly = display.newImageRect(settings.IMAGE_FOLDER .. 'fly.png', 260, 251);
    
    fly.x = world_recipe.starting_point.x;
    fly.y = world_recipe.starting_point.y;

    fly.xScale = -0.4;
    fly.yScale = 0.4;

    fly_group:insert(fly);

    fly_destination = {};
    fly_destination.x = fly.x;
    fly_destination.y = fly.y;

    fly:play()
end

------------------------------------------------------------------

function scene:show(event)

    local scene_group = self.view;
    local phase = event.phase;

    -- Called when the scene is still off screen (but is about to come on screen)

    if (phase == "will") then

        camera:update(camera_group, fly, world_recipe.frame);

    -- Called when the scene is now on screen
    -- Insert code here to make the scene come alive
    -- Example: start timers, begin animation, play audio, etc.

    elseif (phase == "did") then
        
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

    if (phase == "will") then

        removeLocationListener();

    -- Called immediately after scene goes off screen

    elseif (phase == "did") then
        
        composer.removeScene('world');
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