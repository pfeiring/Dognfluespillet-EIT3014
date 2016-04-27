
local collision = {};

------------------------------------------------------------------

function collision:box_x(fly, object)
	return (math.abs(fly.x - object.x) < (fly.collision_width + object.width) / 2);
end

function collision:box_y(fly, object)
	return (math.abs(fly.y - object.y) < (fly.collision_height + object.height) / 2);
end

function collision:box(fly, object)
	return (collision:box_x(fly, object) and collision:box_y(fly, object));
end

return collision;