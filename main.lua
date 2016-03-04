
local latitudeDisplay = display.newText( '-', 100, 50, native.systemFont, 16 )
local longitudeDisplay = display.newText( '-', 100, 100, native.systemFont, 16 )
local altitudeDisplay = display.newText( '-', 100, 150, native.systemFont, 16 )
local accuracyDisplay = display.newText( '-', 100, 200, native.systemFont, 16 )
local speedDisplay = display.newText( '-', 100, 250, native.systemFont, 16 )
local directionDisplay = display.newText( '-', 100, 300, native.systemFont, 16 )
local timeDisplay = display.newText( '-', 100, 350, native.systemFont, 16 )

------------------------------------------------------------------
-- Get recipe for level 
--  Starting point
--	Objects: width, height, source, parallax effect
--	List of portals
--	List of treasures
--	List of landmarks

local level_recipe = {};

level_recipe.starting_point = {100, 100};
level_recipe.objects = {};
level_recipe.portals = {};
level_recipe.treasures = {};

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

local background = display.newRect(200, 200, 100, 100); background:setFillColor(0, 1, 1);
local player = display.newRect(200, 200, 20, 20); player:setFillColor(1, 0, 0);

background_group:insert(background);
player_group:insert(player);

------------------------------------------------------------------

local SCREEN_WIDTH = display.contentWidth;
local SCREEN_HEIGHT = display.contentHeight;

------------------------------------------------------------------

local settings = {};

settings.DEBUG_WITH_DATA    = false;
settings.DEBUG_WITH_EVENT   = true;

settings.TIME_TRESHOLD      = 1;
settings.DISTANCE_THRESHOLD = 0.00015;

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

            background_group.x = background_group.x - 20 * math.cos(movement.direction);
            background_group.y = background_group.y + 20 * math.sin(movement.direction);

			-- Check for portals
			-- Check for treasures
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
