
local fly = {};

------------------------------------------------------------------

local settings = require('settings');

------------------------------------------------------------------

local fly_object = {};
local fly_destination = {};

------------------------------------------------------------------

function fly:construct(world_recipe, fly_group)

	local sheet_options = 
    {
        width 				= 657,
        height 				= 626,
        numFrames 			= 9,
        sheetContentWidth 	= 5921,
        sheetContentHeight 	= 626
    };
    
    local sheet_flying_fly = graphics.newImageSheet(settings.IMAGE_FOLDER .. 'sprite_fly.png', sheet_options);
    
    local sequences_flying_fly = {
        {
            name = 'normalFlying',
            start = 1,
            count = 9,
            time = 1000,
            loopCount = 0,
            loopDirection = 'forward'
        }
    };

    ------------------------------------------------------------------

    fly_object = display.newSprite(sheet_flying_fly, sequences_flying_fly);
    
    fly_object.x = world_recipe.starting_point.x;
    fly_object.y = world_recipe.starting_point.y;

    fly_object.xScale = -0.4;
    fly_object.yScale = 0.4;

    fly_group:insert(fly_object);

    fly_destination = {};
    fly_destination.x = fly_object.x;
    fly_destination.y = fly_object.y;

    fly_object:play();
end

------------------------------------------------------------------

function fly:get_object()
    return fly_object;
end

function fly:get_position()
	return {x = fly_object.x; y = fly_object.y};
end

------------------------------------------------------------------

function fly:add_to_destination(delta_x, delta_y)

    fly_destination.x = fly_destination.x + delta_x;
    fly_destination.y = fly_destination.y + delta_y;
end

------------------------------------------------------------------

function fly:update()
    
    local delta_x = fly_destination.x - fly_object.x;
    local delta_y = fly_destination.y - fly_object.y;
    
    local alpha = math.atan2(-delta_y, delta_x);

    local delta_speed = (delta_x * delta_x) + (delta_y * delta_y);

    local step_x;
    local step_y;

    if (delta_speed < (settings.FLY_SPEED * settings.FLY_SPEED)) then
        step_x = math.sqrt(delta_speed) * math.cos(alpha);
        step_y = math.sqrt(delta_speed) * math.sin(alpha);
    else
        step_x = settings.FLY_SPEED * math.cos(alpha);
        step_y = settings.FLY_SPEED * math.sin(alpha);
    end

    fly_object.x = fly_object.x + step_x;
    fly_object.y = fly_object.y - step_y;

    if (step_x > 0.01 * settings.FLY_SPEED) then
        fly_object.xScale = -0.4;
    elseif (step_x < -0.01 * settings.FLY_SPEED) then
        fly_object.xScale = 0.4;
    end
end

return fly;