
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

------------------------------------------------------------------

local settings = {};

settings.DEBUG_WITH_DATA    = false;
settings.DEBUG_WITH_EVENT   = true;

settings.TIME_TRESHOLD      = 1;
settings.DISTANCE_THRESHOLD = 0.00015;

settings.STEP_SIZE          = 100;

------------------------------------------------------------------
-- Recipe for level 
--  Starting point
--	Objects: width, height, source, parallax effect
--	List of portals
--	List of treasures
--	List of landmarks

local level_recipe = {};

level_recipe.starting_point = {400, 480};

level_recipe.objects = {};
level_recipe.objects[1] = {file = 'world.png', width = 3080 * 0.8, height = 1909 * 0.8, x = 1200, y = 220 };

level_recipe.portals = {};

level_recipe.treasures = {};
level_recipe.treasures[1] = {x = 700, y = 500};

-- World group determines drawing order of group
-- Need a group for background
-- Need a group for game objects
-- Need a group for player
-- Need a group for UI 

local world_group = display.newGroup();

local background_group = display.newGroup();
local objects_group = display.newGroup();
local player_group = display.newGroup();
local UI_group = display.newGroup();

world_group:insert(background_group);
world_group:insert(objects_group);
world_group:insert(player_group);
world_group:insert(UI_group);

-- Construct the world

local objects = {};

for i = 1, #level_recipe.objects do
	
	local recipe = level_recipe.objects[i];
	local object = display.newImageRect(recipe.file, recipe.width, recipe.height);

	object.x = recipe.x;
	object.y = recipe.y;

	objects[#objects + 1] = object;
	objects_group:insert(object);
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
player.x = level_recipe.starting_point[1];
player.y = level_recipe.starting_point[2];
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

local location_handler = function( event )

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

			-- Move objects
			
			for i = 1, #objects do
            	objects[i].x = objects[i].x - settings.STEP_SIZE * math.cos(movement.direction);
				objects[i].y = objects[i].y + settings.STEP_SIZE * math.sin(movement.direction);
			end

			for i = 1, #treasures do
            	treasures[i].x = treasures[i].x - settings.STEP_SIZE * math.cos(movement.direction);
				treasures[i].y = treasures[i].y + settings.STEP_SIZE * math.sin(movement.direction);
			end

			-- Check for portals
			
			-- Check for treasure takings
		
			for i = 1, #treasures do
				if (collides(player, treasures[i])) then
					treasures[i].isVisible = false;	
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

local debug_with_event_detector = display.newRect(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, SCREEN_WIDTH, SCREEN_HEIGHT);
debug_with_event_detector.isVisible = false;
debug_with_event_detector.isHitTestable = true;

local debug_handler_event = function(event)
	
	debug_handler();

	if (event.phase == 'ended') then
			
		if (event.y < (SCREEN_HEIGHT / 2)) then
			debug_event.latitude = debug_event.latitude + DEBUG_INCREMENT;
		else
			debug_event.latitude = debug_event.latitude - DEBUG_INCREMENT;
		end						
		
		if (event.x > (SCREEN_WIDTH / 2)) then
			debug_event.longitude = debug_event.longitude + DEBUG_INCREMENT;
		else
			debug_event.longitude = debug_event.longitude - DEBUG_INCREMENT;
		end						
	end
end

------------------------------------------------------------------
-- Run location

if (settings.DEBUG_WITH_DATA) then
    timer.performWithDelay(50, debug_handler_data, -1);
elseif (settings.DEBUG_WITH_EVENT) then
	debug_with_event_detector:addEventListener('touch', debug_handler_event);
else
    Runtime:addEventListener('location', location_handler);
end
