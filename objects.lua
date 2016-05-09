
local objects = {};
local composer = require('composer');

------------------------------------------------------------------

local c 		= require('c');
local settings 	= require('settings');
local utilities = require('utilities');
local events 	= require('events');
local collision = require('collision');
local UI 		= require('UI');
local fly_class = require('fly');

------------------------------------------------------------------

local container = {};

function objects:reset()
	container = {};
end

------------------------------------------------------------------

function objects:construct(world_recipe, objects_group, storage_object, front_objects_group)

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
        object.ppx = recipe.ppx;
        object.ppy = recipe.ppy;
        object.max_x = recipe.max_x;
        object.max_y = recipe.max_y;
        object.particle_speed_x = recipe.particle_speed_x;
        object.particle_speed_y = recipe.particle_speed_y;

        container[#container + 1] = object;
        objects_group:insert(object);

        if (recipe.front_object) then
            front_objects_group:insert(object);
        end

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

            elseif (body == c.CARNIV) then

                object.im_1 = recipe.im_1;
                object.im_2 = recipe.im_2;
                object.im_3 = recipe.im_3;
                object.closed_front = recipe.closed_front;
                object.closed_back = recipe.closed_back;
                object.im2_time = recipe.im2_time;
                object.im3_time = recipe.im3_time;
                object.closed_time = recipe.closed_time;
                object.eat_time = recipe.eat_time;
                object.counter = recipe.counter;
                object.storage_object = storage_object;

            elseif (body == c.LAMP) then

                object.lamp_on = recipe.lamp_on;
                object.lamp_off = recipe.lamp_off;
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
            transition.to( object, {time = 0, x = object.ppx -(camera_offset.x * object.perspective_factor), y = object.ppy -(camera_offset.y * object.perspective_factor)});
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
	
    local fly_object = fly:get_object();

	for i = 1, #container do

        local object = container[i];
        
        if (object.body == c.MESSAGE and not object.taken and collision:box(fly_object, object)) then
            
            object.taken = true;
            UI:show_message(object.message_index);

        elseif (object.body == c.TREASURE and not object.taken and collision:box(fly_object, object)) then

            object.taken = true;
            object.isVisible = false;

            UI:update_happy_meter(object.happy_meter_gain);

        elseif (object.body == c.PORTAL and not object.taken and collision:box(fly_object, object)) then

            local portal = object;

            if (portal.allow_collision) then

                local storage_object = portal.storage_object;

                portal.taken = true;
                UI:update_happy_meter(settings.HAPPY_METER_UPDATE_PORTAL);

                storage_object.portal_activated  = true;
                storage_object.portal_world_name = portal.world_name;
            end
        elseif (object.body == c.CARNIV and collision:box(fly_object, object)) then
                
            local plant = object;

            if (plant.counter > plant.eat_time) then

                --Insta death:
                --plant.storage_object.changing_scene = true;
                --composer.gotoScene('scene_end');

                UI:update_happy_meter(settings.HAPPY_METER_UPDATE_PORTAL);

                plant.storage_object.portal_activated = true;
                plant.storage_object.portal_world_name = c.WORLD_BALLOON;

            elseif (plant.counter > plant.closed_time) then

                container[plant.closed_front].isVisible = true;
                container[plant.closed_back].isVisible = true;
                container[plant.im_3].isVisible = false;

                fly_class:set_destination(350, 900);

            elseif (plant.counter > plant.im3_time) then
                
                container[plant.im_3].isVisible = true;
                container[plant.im_2].isVisible = false;
                
            elseif (plant.counter > plant.im2_time) then

                container[plant.im_2].isVisible = true;
                container[plant.im_1].isVisible = false;
            end

            plant.counter = plant.counter +1;

        elseif (object.body == c.LAMP and not object.taken and collision:box(fly_object, object)) then

            local lamp = object;

            container[lamp.lamp_on].isVisible = true;
            container[lamp.lamp_off].isVisible = false;

            lamp.taken = true;

            fly:swap_sheet();

        end
    end
end

function objects:update_particles()

    for i = 1, #container do

        local object = container[i];

        if (object.particle_speed_x and object.perspective_factor) then
            
            object.ppx = object.ppx + object.particle_speed_x;
            if (object.ppx > object.max_x) then
                object.ppx = -object.max_x;
            elseif (object.ppx < -object.max_x) then
                object.ppx = object.max_x;
            end
            object.ppy = object.ppy + object.particle_speed_y;
            if (object.ppy > object.max_y) then
                object.ppy = -object.max_y;
            elseif (object.ppy < -object.max_y) then
                object.ppy = object.max_y;
            end
        end
    end
end

return objects;