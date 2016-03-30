
display.setStatusBar(display.HiddenStatusBar);
display.setDefault('background', 1, 1, 1);

------------------------------------------------------------------

local c             = require('c');
local utilities     = require('utilities');
local world_recipes = require('world_recipes');
local collision     = require('collision');
local events        = require('events');
local camera        = require('camera');

------------------------------------------------------------------
-- Basic settings

local IMAGE_FOLDER                  = 'images/';

local DEBUG_WITH_DATA               = false;
local DEBUG_WITH_EVENT              = true;

local LOCATION_TIME_TRESHOLD        = 1;
local LOCATION_DISTANCE_THRESHOLD   = 0.00015;
local LOCATION_STEP_SIZE            = 100;

local GAME_DURATION_IN_MINUTES      = 0.2;               -- Minutes

------------------------------------------------------------------

local world_recipe = world_recipes:get(world_recipes.BALLOON);

------------------------------------------------------------------
-- Master group determines drawing order of groups
-- Camera group determines drawing order of in game objects

local background_group = display.newGroup();
local objects_group = display.newGroup();
local player_group = display.newGroup();
local camera_group = display.newGroup();

local UI_group = display.newGroup();

local master_group = display.newGroup();

camera_group:insert(background_group);
camera_group:insert(objects_group);
camera_group:insert(player_group);

master_group:insert(camera_group);
master_group:insert(UI_group);

------------------------------------------------------------------
-- UI

local UI = {};

------------------------------------------------------------------

UI.happy_meter = display.newRect(0, 0, 50, 100);
UI.happy_meter.x = 20 + 50 + 20;
UI.happy_meter.y = 20;
UI.happy_meter:setFillColor(0, 0, 1);
UI.happy_meter.anchorX = 0;
UI.happy_meter.anchorY = 0;
UI.happy_meter.yScale = 0.5;

function UI.happy_meter:update(self, increase)
    UI.happy_meter.yScale = math.min(1, UI.happy_meter.yScale + increase);
end

------------------------------------------------------------------

UI.clock = display.newRect(0, 0, 50, 100);
UI.clock.x = 20;
UI.clock.y = 20;
UI.clock:setFillColor(0, 1, 0);
UI.clock.anchorX = 0;
UI.clock.anchorY = 0;
UI.clock.yScale = 1;
UI.clock.start_time = os.time();

function UI.clock:update(self)

    local current_time = os.time();
    local elapsed_time = current_time - UI.clock.start_time;
    
    if (elapsed_time >= (GAME_DURATION_IN_MINUTES * 60)) then
        UI.clock.yScale = 1;
        UI.clock.isVisible = false;
    else
        UI.clock.yScale = 1 - (elapsed_time / (GAME_DURATION_IN_MINUTES * 60));
    end
end

------------------------------------------------------------------

UI.message = {};
UI.message.index = -1;
UI.message.entry = -1;

UI.message_background = display.newImageRect(IMAGE_FOLDER .. 'message_background.png', 640, 640);
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

UI_group:insert(UI.happy_meter);
UI_group:insert(UI.message_background);
UI_group:insert(UI.message_text);

------------------------------------------------------------------
-- Construct the world

local objects = {};

for i = 1, #world_recipe.objects do
	
	local recipe = world_recipe.objects[i];
	local object;

    -- Asset

    if (recipe.rectangle) then
        object = display.newRect(0, 0, recipe.width, recipe.height);
    else
        object = display.newImageRect(IMAGE_FOLDER .. recipe.file, recipe.width, recipe.height);
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

	objects[#objects + 1] = object;
	objects_group:insert(object);

    -- Collision

    if (recipe.body) then

        local body = recipe.body;

        if (body == c.MESSAGE) then
            object.message_index = recipe.message_index;
        end
    end

    -- Events

    if (recipe.event) then
        
        local event = recipe.event;
        
        if (event.type == c.BALLOON) then

            object.offset = {};
            object.offset.x = event.offset.x;
            object.offset.y = event.offset.y;
            
            object:addEventListener('tap', events.balloon_event);

        elseif (event.type == c.WAVE) then

            object:addEventListener('tap', events.wave_event);

        elseif (event.type == c.ACTIVATOR) then
            
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

local player = display.newRect(0, 0, 50, 50);
player.x = world_recipe.starting_point.x;
player.y = world_recipe.starting_point.y;
player:setFillColor(1, 0, 0);

player_group:insert(player);

------------------------------------------------------------------

local previous_location;
local current_location;
local delta_location;

local location_handler = function(event)

    ------------------------------------------------------------------
    -- Check for error (user may have turned off location services)

    if (event.errorCode) then

        native.showAlert( 'GPS Location Error', event.errorMessage, {'OK'} )
        print( 'Location error: ' .. tostring( event.errorMessage ) )

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

        if (delta_location.time > LOCATION_TIME_TRESHOLD) then

            -- Euclidean distance from longitude and latitude

            movement.distance  = math.sqrt(delta_location.latitude * delta_location.latitude + delta_location.longitude * delta_location.longitude);
            movement.direction = math.atan2(delta_location.latitude, delta_location.longitude);

            if (movement.distance >= LOCATION_DISTANCE_THRESHOLD) then

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

            local step_x = LOCATION_STEP_SIZE * math.cos(movement.direction);
            local step_y = LOCATION_STEP_SIZE * math.sin(movement.direction);

            player.x = player.x + step_x;
            player.y = player.y - step_y;

            camera:update(camera_group, player, world_recipe.frame);

            -- Collision checks

            for i = 1, #objects do

                local object = objects[i];

                if (object.body == c.MESSAGE and not object.taken and collision:box(player, object)) then
                    
                    object.taken = true;
                    UI.message:show(object.message_index);
                end
            end
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

local game_loop = function(event)
    
    UI.clock:update();
end

------------------------------------------------------------------
-- Run

camera:update(camera_group, player, world_recipe.frame);

-- Location

if (DEBUG_WITH_DATA) then
    timer.performWithDelay(50, debug_handler_data, -1);
elseif (DEBUG_WITH_EVENT) then
	debug_with_event_detector:addEventListener('tap', debug_handler_event);
else
    Runtime:addEventListener('location', location_handler);
end

-- Game loop

Runtime:addEventListener('enterFrame', game_loop);
