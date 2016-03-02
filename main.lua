
local player = display.newRect(200, 200, 20, 20); player:setFillColor(1, 0, 0);

local latitudeDisplay = display.newText( '-', 100, 50, native.systemFont, 16 )
local longitudeDisplay = display.newText( '-', 100, 100, native.systemFont, 16 )
local altitudeDisplay = display.newText( '-', 100, 150, native.systemFont, 16 )
local accuracyDisplay = display.newText( '-', 100, 200, native.systemFont, 16 )
local speedDisplay = display.newText( '-', 100, 250, native.systemFont, 16 )
local directionDisplay = display.newText( '-', 100, 300, native.systemFont, 16 )
local timeDisplay = display.newText( '-', 100, 350, native.systemFont, 16 )

------------------------------------------------------------------

local settings = {};

settings.DEBUG_MODE         = true;

settings.TIME_TRESHOLD      = 10;
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

            player.x = player.x + 20 * math.cos(movement.direction);
            player.y = player.y + 20 * math.sin(movement.direction);
        end
    end
end

------------------------------------------------------------------
-- Debug

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

    if (debug_iteration % 10 == 0) then

        if (math.random() < 0.5) then
            debug_event.longitude = debug_event.longitude + 0.0001;
        else
            debug_event.latitude = debug_event.latitude + 0.0001;
        end
    end
end

------------------------------------------------------------------
-- Run location

if (settings.DEBUG_MODE) then
    timer.performWithDelay(500, debug_handler, -1);
else
    Runtime:addEventListener('location', location_handler);
end
