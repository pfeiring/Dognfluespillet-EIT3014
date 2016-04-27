
local camera = {};

------------------------------------------------------------------

local c 		= require('c');
local settings  = require('settings');

------------------------------------------------------------------

function camera:initialize(world_recipe)

    camera.mode = world_recipe.camera_mode;

    camera.target_position_x = world_recipe.camera_target_position_x;
    camera.target_position_y = world_recipe.camera_target_position_y;
end

------------------------------------------------------------------

function camera:update(camera_group, fly_position, world_recipe_frame)

    local offset = {};

    if (camera.mode == c.SIMPLE) then
        offset = camera:simple_update(camera_group, fly_position, world_recipe_frame);
    else
        offset = camera:box_update(camera_group, fly_position, world_recipe_frame);
    end

    return offset;
end

------------------------------------------------------------------

function camera:box_update(camera_group, fly_position, world_recipe_frame)

    local offset_x = camera.target_position_x - fly_position.x;
    local offset_y = camera.target_position_y - fly_position.y;
    
    -- Avoid that the desired camera position in the x direction shows black background

    if (fly_position.x < world_recipe_frame.left + camera.target_position_x) then
       
        offset_x = camera.target_position_x - (world_recipe_frame.left + camera.target_position_x);
    
    elseif (fly_position.x > world_recipe_frame.right - (c.SCREEN_WIDTH - camera.target_position_x)) then
       
        offset_x = camera.target_position_x - (world_recipe_frame.right - (c.SCREEN_WIDTH - camera.target_position_x));
    end

    -- Avoid that the desired camera position in the y direction shows black background

    if (fly_position.y < world_recipe_frame.top + camera.target_position_y) then
    
        offset_y = camera.target_position_y - (world_recipe_frame.top + camera.target_position_y);
    
    elseif (fly_position.y > world_recipe_frame.bottom - (c.SCREEN_HEIGHT - camera.target_position_y)) then
        
        offset_y = camera.target_position_y - (world_recipe_frame.bottom - (c.SCREEN_HEIGHT - camera.target_position_y));
    end

    camera_group.x = offset_x;
    camera_group.y = offset_y;

    local offset = {x = offset_x, y = offset_y};

    return offset;
end

------------------------------------------------------------------

function camera:simple_update(camera_group, fly_position, world_recipe_frame)

    local offset_x = camera.target_position_x - fly_position.x;
    local offset_y = camera.target_position_y - fly_position.y;

    camera_group.x = offset_x;
    camera_group.y = offset_y;

    local offset = {x = offset_x, y = offset_y};

    return offset;
end

return camera;