
display.setStatusBar(display.HiddenStatusBar);

display.setDefault('background', 1, 1, 1);

------------------------------------------------------------------

local latitudeDisplay = display.newText( '-', 100, 50, native.systemFont, 16 )
local longitudeDisplay = display.newText( '-', 100, 100, native.systemFont, 16 )
local altitudeDisplay = display.newText( '-', 100, 150, native.systemFont, 16 )
local accuracyDisplay = display.newText( '-', 100, 200, native.systemFont, 16 )
local speedDisplay = display.newText( '-', 100, 250, native.systemFont, 16 )
local directionDisplay = display.newText( '-', 100, 300, native.systemFont, 16 )
local timeDisplay = display.newText( '-', 100, 350, native.systemFont, 16 )

------------------------------------------------------------------

local SCREEN_WIDTH = display.contentWidth;
local SCREEN_HEIGHT = display.contentHeight;

local HALF_SCREEN_WIDTH = SCREEN_WIDTH * 0.5;
local HALF_SCREEN_HEIGHT = SCREEN_HEIGHT * 0.5;

------------------------------------------------------------------
-- Basic settings

local IMAGE_FOLDER          = 'images/';

local DEBUG_WITH_DATA       = false;
local DEBUG_WITH_EVENT      = true;

local TIME_TRESHOLD         = 1;
local DISTANCE_THRESHOLD    = 0.00015;

local STEP_SIZE             = 100;

------------------------------------------------------------------
-- Enum

local NONE          = 1;
local BALOON        = 2;
local TREASURE      = 3;
local WAVE          = 4;
local ACTIVATOR     = 5;
local MESSAGE       = 6;

------------------------------------------------------------------
-- Utility functions

local value_or_default = function(value, default)
    
    if (value) then
        return value;
    end

    return default;
end

local conditioned_value_or_default = function(condition, value, default)
    
    if (condition) then
        return value;
    end

    return default;
end

------------------------------------------------------------------
-- Recipe for level 
--  Starting point
--	Objects: width, height, source, parallax effect
--	List of portals
--	List of treasures
--	List of landmarks

local level_recipe = {};

level_recipe.starting_point = {};
level_recipe.starting_point.x = 100;
level_recipe.starting_point.y = 650;

------------------------------------------------------------------

level_recipe.frame = {};
level_recipe.frame.width = 2856 * 0.8;
level_recipe.frame.height = 2856 * 0.8;
level_recipe.frame.x = 0;
level_recipe.frame.y = 0;

level_recipe.frame.left = level_recipe.frame.x - level_recipe.frame.width / 2;
level_recipe.frame.right = level_recipe.frame.x + level_recipe.frame.width / 2;
level_recipe.frame.top = level_recipe.frame.y - level_recipe.frame.height / 2;
level_recipe.frame.bottom = level_recipe.frame.y + level_recipe.frame.height / 2;

------------------------------------------------------------------

local index = 0;

level_recipe.objects = {};
level_recipe.objects[index + 1] = {file = 'world_bw.png', body = NONE, width = 2856 * 0.8, height = 2856 * 0.8, x = 0, y = 0 };
--level_recipe.objects[1] = {file = 'world.jpeg', width = 2453 * 0.8, height = 1532 * 0.8, x = 950, y = 320 };
--level_recipe.objects[2] = {file = 'floating.png', body = NONE, movement = FLOATING, width = 696 * 0.8, height = 717 * 0.8, x = -560, y = -470 };

level_recipe.objects[index + 2] = {file = 'balloon_1.png', event = {type = BALOON, offset = {x = -100, y = -200}}, width = 300 * 0.8, height = 300 * 0.8, x = -760, y = -150 };
level_recipe.objects[index + 3] = {file = 'balloon_2.png', event = {type = BALOON, offset = {x = -20, y = -200}}, width = 127 * 0.8, height = 138 * 0.8, x = 930, y = -200 };
level_recipe.objects[index + 4] = {file = 'balloon_3.png', event = {type = BALOON, offset = {x = -20, y = -200}}, width = 151 * 0.8, height = 173 * 0.8, x = 1000, y = -220 };
level_recipe.objects[index + 5] = {file = 'balloon_3.png', event = {type = BALOON, offset = {x = 100, y = -150}}, width = 151 * 0.8, height = 173 * 0.8, x = 100, y = -650 };
level_recipe.objects[index + 6] = {file = 'balloon_2.png', event = {type = BALOON, offset = {x = 150, y = -60}}, width = 127 * 0.8, height = 138 * 0.8, x = 150, y = 550 };

index = index + 6;

level_recipe.objects[index + 1] = {file = 'fish.png', id = 1, width = 400 * 0.8, height = 400 * 0.8, x = 100, y = 980 };
level_recipe.objects[index + 2] = {file = 'wave.png', event = {type = WAVE}, link = 1, width = 400 * 0.8, height = 400 * 0.8, x = 100, y = 980 };

level_recipe.objects[index + 3] = {file = 'fish.png', id = 2, width = 400 * 0.8, height = 400 * 0.8, x = 440, y = 720 };
level_recipe.objects[index + 4] = {file = 'wave.png', event = {type = WAVE}, link = 2, width = 400 * 0.8, height = 400 * 0.8, x = 440, y = 720 };

index = index + 4;

level_recipe.objects[index + 1] = {file = 'lighthouse_light.png', id = 50, invisible = true, width = 606 * 0.8, height = 600 * 0.8, x = 990, y = 290 };
level_recipe.objects[index + 2] = {file = 'lighthouse.png', event = {type = ACTIVATOR}, link = 50, width = 294 * 0.8, height = 283 * 0.8, x = 1000, y = 290 };

index = index + 2;

level_recipe.objects[index + 1] = {rectangle = true, body = TREASURE, width = 30, height = 30, fill_color = {1, 1, 0}, x = 0,  y = 100};
level_recipe.objects[index + 2] = {rectangle = true, body = TREASURE, width = 30, height = 30, fill_color = {1, 1, 0}, x = -200,  y = 100};

index = index + 1;

level_recipe.objects[index + 1] = {rectangle = true, body = MESSAGE, alpha = 0.4, message_index = 1, width = 400, height = 400, fill_color = {0, 0, 1}, x = 0,  y = 100};
level_recipe.objects[index + 2] = {rectangle = true, body = MESSAGE, alpha = 0.4, message_index = 2, width = 200, height = 1000, fill_color = {0, 0, 1}, x = 500,  y = 400};
level_recipe.objects[index + 3] = {rectangle = true, body = MESSAGE, alpha = 0.4, message_index = 3, width = 500, height = 700, fill_color = {0, 0, 1}, x = -500,  y = -400};

------------------------------------------------------------------

local messages = {};

messages[1] =   {
                    'Hadde jeg levd lenger enn et døgn så skulle jeg ha flydd en av disse ballongene.'
                };
messages[2] =   {
                    'Jeg tror jeg ser et fyrtårn der borte!',
                    'Skal vi dra dit?'
                };
messages[3] =   {
                    'Wow! Et svevende hus!',
                    'Nok om meg, opplever du noe spennende?'
                };

------------------------------------------------------------------
-- Master group determines drawing order of groups
-- Camera group determines drawing order of in game objects

local background_group = display.newGroup();
local objects_group = display.newGroup();
local player_group = display.newGroup();
local camera = display.newGroup();

local UI_group = display.newGroup();

local master_group = display.newGroup();

camera:insert(background_group);
camera:insert(objects_group);
camera:insert(player_group);

master_group:insert(camera);
master_group:insert(UI_group);

------------------------------------------------------------------
-- Camera

local SIMPLE = 1;
local BOX = 2;

camera.mode = SIMPLE;

camera.TARGET_POSITION_X = HALF_SCREEN_WIDTH;
camera.TARGET_POSITION_Y = HALF_SCREEN_HEIGHT;

function camera:update(player)

    if (camera.mode == SIMPLE) then
        camera:simple_update(player);
    else
        camera:box_update(player);
    end
end

function camera:box_update(player)

    local offset_x = camera.TARGET_POSITION_X - player.x;
    local offset_y = camera.TARGET_POSITION_Y - player.y;
    
    -- Avoid that the desired camera position in the x direction shows black background

    if (player.x < level_recipe.frame.left + camera.TARGET_POSITION_X) then
       
        offset_x = camera.TARGET_POSITION_X - (level_recipe.frame.left + camera.TARGET_POSITION_X);
    
    elseif (player.x > level_recipe.frame.right - (SCREEN_WIDTH - camera.TARGET_POSITION_X)) then
       
        offset_x = camera.TARGET_POSITION_X - (level_recipe.frame.right - (SCREEN_WIDTH - camera.TARGET_POSITION_X));
    end

    -- Avoid that the desired camera position in the y direction shows black background

    if (player.y < level_recipe.frame.top + camera.TARGET_POSITION_Y) then
    
        offset_y = camera.TARGET_POSITION_Y - (level_recipe.frame.top + camera.TARGET_POSITION_Y);
    
    elseif (player.y > level_recipe.frame.bottom - (SCREEN_HEIGHT - camera.TARGET_POSITION_Y)) then
        
        offset_y = camera.TARGET_POSITION_Y - (level_recipe.frame.bottom - (SCREEN_HEIGHT - camera.TARGET_POSITION_Y));
    end

    camera.x = offset_x;
    camera.y = offset_y;
end

function camera:simple_update(player)

    local offset_x = camera.TARGET_POSITION_X - player.x;
    local offset_y = camera.TARGET_POSITION_Y - player.y;

    camera.x = offset_x;
    camera.y = offset_y;
end

------------------------------------------------------------------
-- UI

local UI = {};

------------------------------------------------------------------

UI.happy_meter = display.newRect(0, 0, 50, 100);
UI.happy_meter.x = 20;
UI.happy_meter.y = 20;
UI.happy_meter:setFillColor(0, 0, 1);
UI.happy_meter.anchorX = 0;
UI.happy_meter.anchorY = 0;
UI.happy_meter.yScale = 0.5;

function UI.happy_meter:update(self, increase)
    UI.happy_meter.yScale = math.min(1, UI.happy_meter.yScale + increase);
end

------------------------------------------------------------------

UI.message = {};
UI.message.index = -1;
UI.message.entry = -1;

UI.message_background = display.newImageRect(IMAGE_FOLDER .. 'message_background.png', 640, 640);
UI.message_background.x = HALF_SCREEN_WIDTH;
UI.message_background.y = HALF_SCREEN_HEIGHT + 350;
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

    if (#messages[UI.message.index] >= UI.message.entry) then

        local message = messages[UI.message.index];
        local message_text = message[UI.message.entry];

        UI.message_text.text = message_text;
    else
        UI.message.index = -1;
        UI.message.entry = -1;

        UI.message_background.isVisible = false;
        UI.message_text.isVisible = false;
    end
end

function UI.message:show(message_index)

    UI.message.index = message_index;
    UI.message.entry = 1;

    local message = messages[UI.message.index];
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
-- Event

local balloon_event = function(event)
    
    local object = event.target;

    if (not object.in_transition) then

        local offset_x = object.offset.x;
        local offset_y = object.offset.y;

        if (object.transitioned) then
            
            offset_x = -offset_x;
            offset_y = -offset_y;

            object.transitioned = nil;
        else
            object.transitioned = true;
        end

        transition.to(object, { transition = easing.inOutQuad,
                                time = 8000,
                                x = object.x + offset_x,
                                y = object.y + offset_y,
                                onComplete = function() object.in_transition = nil; end});

        object.in_transition = true;
    end

    return true;
end

local wave_event = function(event)

    local wave = event.target;
    local fish = wave.link;


    if (not wave.in_transition) then

        wave.in_transition = true;

        transition.to(fish, {transition = easing.outQuad, time = 1000, y = fish.y - 100});
        transition.to(fish, {delay = 500, transition = easing.inOutBack, time = 500, rotation = 180});
        transition.to(fish, {delay = 1100, transition = easing.inQuad, time = 700, y = fish.y});
        transition.to(fish, {delay = 2000, transition = easing.linear, time = 30, rotation = 0, onComplete =
                function()
                    wave.in_transition = false;
                end});
    end

    return true;
end

local activator_event = function(event)

    local activator = event.target;
    local target = activator.link;

    target.isVisible = not target.isVisible;

    return true;
end

------------------------------------------------------------------
-- Construct the world

local objects = {};

for i = 1, #level_recipe.objects do
	
	local recipe = level_recipe.objects[i];
	local object;

    -- Asset

    if (recipe.rectangle) then
        object = display.newRect(0, 0, recipe.width, recipe.height);
        object:setFillColor(unpack(recipe.fill_color));
    else
        object = display.newImageRect(IMAGE_FOLDER .. recipe.file, recipe.width, recipe.height);
    end

    if (recipe.invisible) then
        object.isVisible = false;
    end

    object.alpha = conditioned_value_or_default(recipe.alpha, recipe.alpha, 1);

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

        if (body == MESSAGE) then
            object.message_index = recipe.message_index;
        end
    end

    -- Events

    if (recipe.event) then
        
        local event = recipe.event;
        
        if (event.type == BALOON) then

            object.offset = {};
            object.offset.x = event.offset.x;
            object.offset.y = event.offset.y;
            
            object:addEventListener('tap', balloon_event);

        elseif (event.type == WAVE) then

            object:addEventListener('tap', wave_event);

        elseif (event.type == ACTIVATOR) then
            
            object:addEventListener('tap', activator_event);
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
player.x = level_recipe.starting_point.x;
player.y = level_recipe.starting_point.y;
player:setFillColor(1, 0, 0);

player_group:insert(player);

------------------------------------------------------------------

local collision = {};

function collision:box_x(object_1, object_2)
	return (math.abs(object_1.x - object_2.x) < (object_1.width + object_2.width) / 2);
end

function collision:box_y(object_1, object_2)
	return (math.abs(object_1.y - object_2.y) < (object_1.height + object_2.height) / 2);
end

function collision:box(object_1, object_2)
	return (collision:box_x(object_1, object_2) and collision:box_y(object_1, object_2));
end

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

        if (delta_location.time > TIME_TRESHOLD) then

            -- Euclidean distance from longitude and latitude

            movement.distance  = math.sqrt(delta_location.latitude * delta_location.latitude + delta_location.longitude * delta_location.longitude);
            movement.direction = math.atan2(delta_location.latitude, delta_location.longitude);

            if (movement.distance >= DISTANCE_THRESHOLD) then

                movement_text = 'You\'ve moved';
                movement.valid = true;

                previous_location = {};
                previous_location.latitude = current_location.latitude;
                previous_location.longitude = current_location.longitude;
                previous_location.time = current_location.time;
            end
        end

        ------------------------------------------------------------------

        local latitudeText = string.format( '%.4f', event.latitude )
        latitudeDisplay.text = latitudeText

        local longitudeText = string.format( '%.4f', event.longitude )
        longitudeDisplay.text = longitudeText

        local altitudeText = string.format( '%.3f', event.altitude )
        altitudeDisplay.text = altitudeText

        local accuracyText = string.format( '%.3f', event.accuracy )
        accuracyDisplay.text = accuracyText

        local speedText = string.format( '%.3f', event.speed )
        speedDisplay.text = speedText
        speedDisplay.text = movement_text;

        local directionText = string.format( '%.3f', event.direction )
        directionDisplay.text = directionText

        if (movement.valid) then
            directionDisplay.text = movement.distance * 100000;
        else
            directionDisplay.text = 'no dist';
        end

        -- Note that 'event.time' is a Unix-style timestamp, expressed in seconds since Jan. 1, 1970
        local timeText = string.format( '%.0f', event.time )
        timeDisplay.text = delta_location.time;

        ------------------------------------------------------------------
        -- Move world

        if (movement.valid) then

            local step_x = STEP_SIZE * math.cos(movement.direction);
            local step_y = STEP_SIZE * math.sin(movement.direction);

            player.x = player.x + step_x;
            player.y = player.y - step_y;

            camera:update(player);

            -- Collision checks

            for i = 1, #objects do

                local object = objects[i];

                if (object.body == MESSAGE and not object.taken and collision:box(player, object)) then
                    
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

local debug_with_event_detector = display.newRect(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
debug_with_event_detector.isVisible = false;
debug_with_event_detector.isHitTestable = true;

local debug_handler_event = function(event)
	
	debug_handler();

    local delta_x = event.x - HALF_SCREEN_WIDTH;
    local delta_y = event.y - HALF_SCREEN_HEIGHT;

    local alpha = math.atan2(delta_y, delta_x);
    local magnitude = delta_x * delta_x + delta_y * delta_y;

    debug_event.longitude = debug_event.longitude + 0.1 * magnitude * math.cos(alpha);
    debug_event.latitude = debug_event.latitude - 0.1 * magnitude * math.sin(alpha);
end

------------------------------------------------------------------
-- Run

camera:update(player);

if (DEBUG_WITH_DATA) then
    timer.performWithDelay(50, debug_handler_data, -1);
elseif (DEBUG_WITH_EVENT) then
	debug_with_event_detector:addEventListener('tap', debug_handler_event);
else
    Runtime:addEventListener('location', location_handler);
end
