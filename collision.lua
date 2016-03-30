
local collision = {};

------------------------------------------------------------------

function collision:box_x(object_1, object_2)
	return (math.abs(object_1.x - object_2.x) < (object_1.width + object_2.width) / 2);
end

function collision:box_y(object_1, object_2)
	return (math.abs(object_1.y - object_2.y) < (object_1.height + object_2.height) / 2);
end

function collision:box(object_1, object_2)
	return (collision:box_x(object_1, object_2) and collision:box_y(object_1, object_2));
end

return collision;