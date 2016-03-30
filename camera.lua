
local camera = {};

------------------------------------------------------------------

local c = require('c');

------------------------------------------------------------------

camera.mode = c.SIMPLE;

camera.TARGET_POSITION_X = c.HALF_SCREEN_WIDTH;
camera.TARGET_POSITION_Y = c.HALF_SCREEN_HEIGHT;

------------------------------------------------------------------

function camera:update(camera_group, player, world_recipe_frame)

    if (camera.mode == SIMPLE) then
        camera:simple_update(camera_group, player, world_recipe_frame);
    else
        camera:box_update(camera_group, player, world_recipe_frame);
    end
end

------------------------------------------------------------------

function camera:box_update(camera_group, player, world_recipe_frame)

    local offset_x = camera.TARGET_POSITION_X - player.x;
    local offset_y = camera.TARGET_POSITION_Y - player.y;
    
    -- Avoid that the desired camera position in the x direction shows black background

    if (player.x < world_recipe_frame.left + camera.TARGET_POSITION_X) then
       
        offset_x = camera.TARGET_POSITION_X - (world_recipe_frame.left + camera.TARGET_POSITION_X);
    
    elseif (player.x > world_recipe_frame.right - (c.SCREEN_WIDTH - camera.TARGET_POSITION_X)) then
       
        offset_x = camera.TARGET_POSITION_X - (world_recipe_frame.right - (c.SCREEN_WIDTH - camera.TARGET_POSITION_X));
    end

    -- Avoid that the desired camera position in the y direction shows black background

    if (player.y < world_recipe_frame.top + camera.TARGET_POSITION_Y) then
    
        offset_y = camera.TARGET_POSITION_Y - (world_recipe_frame.top + camera.TARGET_POSITION_Y);
    
    elseif (player.y > world_recipe_frame.bottom - (c.SCREEN_HEIGHT - camera.TARGET_POSITION_Y)) then
        
        offset_y = camera.TARGET_POSITION_Y - (world_recipe_frame.bottom - (c.SCREEN_HEIGHT - camera.TARGET_POSITION_Y));
    end

    camera_group.x = offset_x;
    camera_group.y = offset_y;
end

------------------------------------------------------------------

function camera:simple_update(camera_group, player, world_recipe_frame)

    local offset_x = camera.TARGET_POSITION_X - player.x;
    local offset_y = camera.TARGET_POSITION_Y - player.y;

    camera_group.x = offset_x;
    camera_group.y = offset_y;
end

return camera;