
local events = {};

------------------------------------------------------------------

local settings = require('settings');

------------------------------------------------------------------

function events.balloon_event(event)
    
    local balloon = event.target;

    if (not balloon.taken) then
        balloon.taken = true;
        balloon.happy_meter:update(settings.HAPPY_METER_UPDATE_BALLOON);
    end

    if (not balloon.in_transition) then

        local offset_x = balloon.offset.x;
        local offset_y = balloon.offset.y;

        if (balloon.transitioned) then
            
            offset_x = -offset_x;
            offset_y = -offset_y;

            balloon.transitioned = nil;
        else
            balloon.transitioned = true;
        end

        transition.to(balloon, { transition = easing.inOutQuad,
                                time = 8000,
                                x = balloon.x + offset_x,
                                y = balloon.y + offset_y,
                                onComplete = function() balloon.in_transition = nil; end});

        balloon.in_transition = true;
    end

    return true;
end

------------------------------------------------------------------

function events.wave_event(event)
	
    local wave = event.target;
    local fish = wave.link;

    if (not wave.taken) then
        wave.taken = true;
        wave.happy_meter:update(settings.HAPPY_METER_UPDATE_WAVE);
    end

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

------------------------------------------------------------------

function events.activator_event(event)

    local activator = event.target;
    local target = activator.link;

    if (not activator.taken) then
        activator.taken = true;
        activator.happy_meter:update(settings.HAPPY_METER_UPDATE_ACTIVATOR);
    end

    target.isVisible = not target.isVisible;

    return true;
end

return events;