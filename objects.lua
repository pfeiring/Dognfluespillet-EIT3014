
local objects = {};

------------------------------------------------------------------

local c 		= require('c');
local settings 	= require('settings');
local utilities = require('utilities');
local events 	= require('events');
local collision = require('collision');
local UI 		= require('UI');

------------------------------------------------------------------

local container = {};

function objects:reset()
	container = {};
end

------------------------------------------------------------------

function objects:construct(world_recipe, objects_group, storage_object)

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

        container[#container + 1] = object;
        objects_group:insert(object);

        -- Collision

        if (recipe.body) then

            local body = recipe.body;

            if (body == c.MESSAGE) then
                
                object.message_index = recipe.message_index;

            elseif (body == c.TREASURE) then

                object.happy_meter_gain = recipe.happy_meter_gain;

            elseif (body == c.PORTAL) then

                object.start_theta  = recipe.start_theta;
                object.r            = recipe.r;
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

            elseif (event.type == c.PORTAL) then

                object.happy_meter = UI.happy_meter;

                object.storage_object  = storage_object;
                object.world_name      = event.world_name;
                object.allow_collision = event.allow_collision;

                object:addEventListener('tap', events.portal_event);
            end
        end
    end
end

------------------------------------------------------------------
-- Setup links between objects

function objects:link()

    for i = 1, #container do

        local object = container[i];
        
        if (object.link) then

            for j = 1, #container do

                local target = container[j];
                
                if (target.id and target.id == object.link) then
                    
                    object.link = target;
                end
            end
        end
    end
end

------------------------------------------------------------------

function objects:simulate_perspective(camera_offset)

	for i = 1, #container do

        local object = container[i];
        
        if (object.perspective_factor) then            
            transition.to( object, {time = 0, x = -(camera_offset.x * object.perspective_factor), y = -(camera_offset.y * object.perspective_factor)});
        end
    end
end

------------------------------------------------------------------

function objects:update()

    for i = 1, #container do

        local object = container[i];

        if (object.body == c.PORTAL) then

            local elapsed_time = system.getTimer();
            local theta = object.start_theta + elapsed_time / 10000;

            object.x = object.r * math.cos(theta);
            object.y = object.r * math.sin(theta);
        end
    end
end

function objects:check_collisions(fly)
	
	for i = 1, #container do

        local object = container[i];
        
        if (object.body == c.MESSAGE and not object.taken and collision:box(fly, object)) then
            
            object.taken = true;
            UI:show_message(object.message_index);

        elseif (object.body == c.TREASURE and not object.taken and collision:box(fly, object)) then

            object.taken = true;
            object.isVisible = false;

            UI:update_happy_meter(object.happy_meter_gain);

        elseif (object.body == c.PORTAL and not object.taken and collision:box(fly, object)) then

            local portal = object;

            if (portal.allow_collision) then

                local storage_object = portal.storage_object;

                portal.taken = true;
                UI:update_happy_meter(settings.HAPPY_METER_UPDATE_PORTAL);

                storage_object.portal_activated  = true;
                storage_object.portal_world_name = portal.world_name;
            end
        end
    end
end

return objects;