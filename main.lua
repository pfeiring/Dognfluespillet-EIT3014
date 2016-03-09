
display.setStatusBar(display.HiddenStatusBar);

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

local settings = {};

settings.DEBUG_WITH_DATA    = false;
settings.DEBUG_WITH_EVENT   = true;

settings.TIME_TRESHOLD      = 1;
settings.DISTANCE_THRESHOLD = 0.00015;

settings.STEP_SIZE          = 100;

------------------------------------------------------------------

local NONE = 1;
local BALOON = 2;

local FLOATING_UP = 1;
local FLOATING_DOWN = 2;

local LEFT = 1;
local RIGHT = 2;

------------------------------------------------------------------
-- Recipe for level 
--  Starting point
--	Objects: width, height, source, parallax effect
--	List of portals
--	List of treasures
--	List of landmarks

local level_recipe = {};

level_recipe.starting_point = {};
level_recipe.starting_point.x = 800;
level_recipe.starting_point.y = 00;

------------------------------------------------------------------

level_recipe.frame = {};
level_recipe.frame.width = 3080 * 0.8;
level_recipe.frame.height = 1909 * 0.8;
level_recipe.frame.x = 0;
level_recipe.frame.y = 0;

level_recipe.frame.left = level_recipe.frame.x - level_recipe.frame.width / 2;
level_recipe.frame.right = level_recipe.frame.x + level_recipe.frame.width / 2;
level_recipe.frame.top = level_recipe.frame.y - level_recipe.frame.height / 2;
level_recipe.frame.bottom = level_recipe.frame.y + level_recipe.frame.height / 2;

------------------------------------------------------------------

level_recipe.objects = {};
level_recipe.objects[1] = {file = 'world_bw.png', body = NONE, width = 3080 * 0.8, height = 1909 * 0.8, x = 0, y = 0 };
--level_recipe.objects[1] = {file = 'world.jpeg', width = 2453 * 0.8, height = 1532 * 0.8, x = 950, y = 320 };
--level_recipe.objects[2] = {file = 'floating.png', body = NONE, movement = FLOATING, width = 696 * 0.8, height = 717 * 0.8, x = -560, y = -470 };
level_recipe.objects[2] = {file = 'balloon_1.png', body = BALOON, movement = FLOATING_DOWN, direction = LEFT, width = 300 * 0.8, height = 300 * 0.8, x = -760, y = -150 };
level_recipe.objects[3] = {file = 'balloon_2.png', body = BALOON, movement = FLOATING_UP, direction = LEFT, width = 127 * 0.8, height = 138 * 0.8, x = 930, y = -200 };
level_recipe.objects[4] = {file = 'balloon_3.png', body = BALOON, movement = FLOATING_DOWN, direction = LEFT, width = 151 * 0.8, height = 173 * 0.8, x = 1000, y = -220 };

level_recipe.portals = {};

level_recipe.treasures = {};
level_recipe.treasures[1] = {x = 0,  y = 100};
level_recipe.treasures[2] = {x = -200, y = 100};

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

camera.TARGET_POSITION_X = HALF_SCREEN_WIDTH;
camera.TARGET_POSITION_Y = HALF_SCREEN_HEIGHT + 200;

function camera:update(player)

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

------------------------------------------------------------------
-- UI

local UI = {};

UI.happy_meter = display.newRect(0, 0, 50, 100);
UI.happy_meter.x = 20;
UI.happy_meter.y = 20;
UI.happy_meter:setFillColor(0, 0, 1);
UI.happy_meter.anchorX = 0;
UI.happy_meter.anchorY = 0;
UI.happy_meter.yScale = 0.5;

function UI.happy_meter:update(increase)
    UI.happy_meter.yScale = math.min(1, UI.happy_meter.yScale + increase);
end

------------------------------------------------------------------

local function movement_floating_down(object, random_position_offset, random_time_offset)
    
    transition.to(object, {transition = easing.inOutQuad, y = object.y + 20 + random_position_offset, time = 5000 + random_time_offset, onComplete =
    function()
        transition.to(object, {transition = easing.inOutQuad, y = object.y - 20 - random_position_offset, time = 5000 + random_time_offset, onComplete = function() movement_floating_down(object, random_position_offset, random_time_offset) end});
    end});
end

local function movement_floating_up(object, random_position_offset, random_time_offset)
    
    transition.to(object, {transition = easing.inOutQuad, y = object.y - 20 - random_position_offset, time = 5000 + random_time_offset, onComplete =
    function()
        transition.to(object, {transition = easing.inOutQuad, y = object.y + 20 + random_position_offset, time = 5000 + random_time_offset, onComplete = function() movement_floating_up(object, random_position_offset, random_time_offset) end});
    end});
end

------------------------------------------------------------------
-- Construct the world

local objects = {};

for i = 1, #level_recipe.objects do
	
	local recipe = level_recipe.objects[i];
	local object = display.newImageRect(recipe.file, recipe.width, recipe.height);

	object.x = recipe.x;
	object.y = recipe.y;

    object.body = recipe.body;
    object.direction = recipe.direction;

	objects[#objects + 1] = object;
	objects_group:insert(object);

    if (recipe.movement) then

        local movement = recipe.movement;
        local random_position_offset = math.random() * 5;
        local random_time_offset = math.ceil(math.random() * 1000);

        if (movement == FLOATING_DOWN) then
            movement_floating_down(object, random_position_offset, random_time_offset);
        elseif (movement == FLOATING_UP) then
            movement_floating_up(object, random_position_offset, random_time_offset);
        end
    end
end

local treasures = {};

for i = 1, #level_recipe.treasures do
	
	local recipe = level_recipe.treasures[i];
	local treasure = display.newRect(0, 0, 30, 30);

	treasure.x = recipe.x;
	treasure.y = recipe.y;
	treasure:setFillColor(1, 1, 0);

	treasures[#treasures + 1] = treasure;
	objects_group:insert(treasure);
end

local player = display.newRect(0, 0, 50, 50);
player.x = level_recipe.starting_point.x;
player.y = level_recipe.starting_point.y;
player:setFillColor(1, 0, 0);

player_group:insert(player);

------------------------------------------------------------------

local collides_x = function(object_1, object_2)
	return (math.abs(object_1.x - object_2.x) < (object_1.width + object_2.width) / 2);
end

local collides_y = function(object_1, object_2)
	return (math.abs(object_1.y - object_2.y) < (object_1.height + object_2.height) / 2);
end

local collides = function(object_1, object_2)
	return (collides_x(object_1, object_2) and collides_y(object_1, object_2));
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

        if (delta_location.time > settings.TIME_TRESHOLD) then

            -- Euclidean distance from longitude and latitude

            movement.distance  = math.sqrt(delta_location.latitude * delta_location.latitude + delta_location.longitude * delta_location.longitude);
            movement.direction = math.atan2(delta_location.latitude, delta_location.longitude);

            if (movement.distance >= settings.DISTANCE_THRESHOLD) then

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

			-- Move player

            local step_x = settings.STEP_SIZE * math.cos(movement.direction);
            local step_y = settings.STEP_SIZE * math.sin(movement.direction);

            player.x = player.x + step_x;
            player.y = player.y - step_y;

            camera:update(player);

            -- Check

            for i = 1, #objects do

                local object = objects[i];

                if (object.body == BALOON and not object.taken and collides(player, objects[i])) then
                    
                    transition.cancel(object);

                    if (object.direction == LEFT) then
                        transition.to(object, {transition = easing.inOutQuad, time = 40000, y = object.y - 2000, x = object.x + 100 * math.random(-5, 1)});
                    else
                        transition.to(object, {transition = easing.inOutQuad, time = 40000, y = object.y - 2000, x = object.x + 100 * math.random(1, 5)});
                    end

                    object.taken = true;
                end
            end
			
			-- Check for treasure takings
		
			for i = 1, #treasures do

                local treasure = treasures[i];

				if (not treasure.taken and collides(player, treasure)) then
					
                    treasure.isVisible = false;
                    treasure.taken = true;

                    UI.happy_meter:update(0.1);
				end
			end

            -- Check for portals

            
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

	if (event.phase == 'ended') then

        local delta_x = event.x - HALF_SCREEN_WIDTH;
        local delta_y = event.y - HALF_SCREEN_HEIGHT;

        local alpha = math.atan2(delta_y, delta_x);
        local magnitude = delta_x * delta_x + delta_y * delta_y;

        debug_event.longitude = debug_event.longitude + 0.1 * magnitude * math.cos(alpha);
        debug_event.latitude = debug_event.latitude - 0.1 * magnitude * math.sin(alpha);
	end
end

------------------------------------------------------------------
-- Run

camera:update(player);

if (settings.DEBUG_WITH_DATA) then
    timer.performWithDelay(50, debug_handler_data, -1);
elseif (settings.DEBUG_WITH_EVENT) then
	debug_with_event_detector:addEventListener('touch', debug_handler_event);
else
    Runtime:addEventListener('location', location_handler);
end
