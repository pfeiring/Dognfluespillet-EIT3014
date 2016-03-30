
local events = {};

------------------------------------------------------------------

function events.balloon_event(event)
    
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

------------------------------------------------------------------

function events.wave_event(event)
	
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

------------------------------------------------------------------

function events.activator_event(event)

    local activator = event.target;
    local target = activator.link;

    target.isVisible = not target.isVisible;

    return true;
end

return events;