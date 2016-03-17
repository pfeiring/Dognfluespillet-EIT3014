
local world_recipes = {};

------------------------------------------------------------------

local c = require('c');

------------------------------------------------------------------

world_recipes.BALLOON = 1;
world_recipes.FLOWERS = 2;

------------------------------------------------------------------

local flowers = function()

	local index = 0;

	local world_recipe = {};

	world_recipe.starting_point = {};
	world_recipe.frame = {};
	world_recipe.objects = {};

	------------------------------------------------------------------
	
	world_recipe.frame = {};
	world_recipe.frame.width = 2856 * 0.8;
	world_recipe.frame.height = 2856 * 0.8;
	world_recipe.frame.x = 0;
	world_recipe.frame.y = 0;

	world_recipe.frame.left = world_recipe.frame.x - world_recipe.frame.width / 2;
	world_recipe.frame.right = world_recipe.frame.x + world_recipe.frame.width / 2;
	world_recipe.frame.top = world_recipe.frame.y - world_recipe.frame.height / 2;
	world_recipe.frame.bottom = world_recipe.frame.y + world_recipe.frame.height / 2;

	------------------------------------------------------------------

	world_recipe.objects[index + 1] = {file = 'world_flowers.jpg', body = NONE, width = 2614, height = 1819, x = 0, y = 0 };	
	world_recipe.objects[index + 2] = {file = 'world_flowers_color.png', id = 1, invisible = true, body = NONE, width = 2614, height = 1819, x = 0, y = 0 };	

	world_recipe.objects[index + 3] = {rectangle = true, event = {type = c.ACTIVATOR}, link = 1, invisible = true, alpha = 0.4, message_index = 3, width = 400, height = 200, fill_color = {0, 0, 1}, x = -100,  y = 800};

	return world_recipe;
end

------------------------------------------------------------------

local balloon = function()

	local index = 0;

	local world_recipe = {};

	world_recipe.starting_point = {};
	world_recipe.frame = {};
	world_recipe.objects = {};

	------------------------------------------------------------------

	world_recipe.starting_point.x = 100;
	world_recipe.starting_point.y = 650;

	------------------------------------------------------------------
	
	world_recipe.frame.width = 2856 * 0.8;
	world_recipe.frame.height = 2856 * 0.8;
	world_recipe.frame.x = 0;
	world_recipe.frame.y = 0;

	world_recipe.frame.left = world_recipe.frame.x - world_recipe.frame.width / 2;
	world_recipe.frame.right = world_recipe.frame.x + world_recipe.frame.width / 2;
	world_recipe.frame.top = world_recipe.frame.y - world_recipe.frame.height / 2;
	world_recipe.frame.bottom = world_recipe.frame.y + world_recipe.frame.height / 2;

	------------------------------------------------------------------
	
	world_recipe.objects[index + 1] = {file = 'world_bw.png', body = NONE, width = 2856 * 0.8, height = 2856 * 0.8, x = 0, y = 0 };

	world_recipe.objects[index + 2] = {file = 'balloon_1.png', event = {type = c.BALLOON, offset = {x = -100, y = -200}}, width = 300 * 0.8, height = 300 * 0.8, x = -760, y = -150 };
	world_recipe.objects[index + 3] = {file = 'balloon_2.png', event = {type = c.BALLOON, offset = {x = -20, y = -200}}, width = 127 * 0.8, height = 138 * 0.8, x = 930, y = -200 };
	world_recipe.objects[index + 4] = {file = 'balloon_3.png', event = {type = c.BALLOON, offset = {x = -20, y = -200}}, width = 151 * 0.8, height = 173 * 0.8, x = 1000, y = -220 };
	world_recipe.objects[index + 5] = {file = 'balloon_3.png', event = {type = c.BALLOON, offset = {x = 100, y = -150}}, width = 151 * 0.8, height = 173 * 0.8, x = 100, y = -650 };
	world_recipe.objects[index + 6] = {file = 'balloon_2.png', event = {type = c.BALLOON, offset = {x = 150, y = -60}}, width = 127 * 0.8, height = 138 * 0.8, x = 150, y = 550 };

	index = index + 6;

	world_recipe.objects[index + 1] = {file = 'fish.png', id = 1, width = 400 * 0.8, height = 400 * 0.8, x = -200 + 100, y = 980 };
	world_recipe.objects[index + 2] = {file = 'wave.png', event = {type = WAVE}, link = 1, width = 400 * 0.8, height = 400 * 0.8, x = -200 + 100, y = 980 };

	world_recipe.objects[index + 3] = {file = 'fish.png', id = 2, width = 400 * 0.8, height = 400 * 0.8, x = -80 + 440, y = 720 };
	world_recipe.objects[index + 4] = {file = 'wave.png', event = {type = WAVE}, link = 2, width = 400 * 0.8, height = 400 * 0.8, x = -80 + 440, y = 720 };

	world_recipe.objects[index + 5] = {file = 'fish.png', id = 3, width = 400 * 0.8, height = 400 * 0.8, x = -200 + 200, y = 830 };
	world_recipe.objects[index + 6] = {file = 'wave.png', event = {type = WAVE}, link = 3, width = 400 * 0.8, height = 400 * 0.8, x = -200 + 200, y = 830 };

	world_recipe.objects[index + 7] = {file = 'fish.png', id = 4, width = 400 * 0.8, height = 400 * 0.8, x = -200 + -100, y = 920 };
	world_recipe.objects[index + 8] = {file = 'wave.png', event = {type = WAVE}, link = 4, width = 400 * 0.8, height = 400 * 0.8, x = -200 + -100, y = 920 };

	index = index + 8;

	world_recipe.objects[index + 1] = {file = 'lighthouse_light.png', id = 50, invisible = true, width = 606 * 0.8, height = 600 * 0.8, x = 990, y = 290 };
	world_recipe.objects[index + 2] = {file = 'lighthouse.png', event = {type = c.ACTIVATOR}, link = 50, width = 294 * 0.8, height = 283 * 0.8, x = 1000, y = 290 };

	index = index + 2;

	world_recipe.objects[index + 1] = {rectangle = true, body = c.TREASURE, width = 30, height = 30, fill_color = {1, 1, 0}, x = 0,  y = 100};
	world_recipe.objects[index + 2] = {rectangle = true, body = c.TREASURE, width = 30, height = 30, fill_color = {1, 1, 0}, x = -200,  y = 100};

	index = index + 1;

	world_recipe.objects[index + 1] = {rectangle = true, body = c.MESSAGE, invisible = true, alpha = 0.4, message_index = 1, width = 400, height = 400, fill_color = {0, 0, 1}, x = 0,  y = 100};
	world_recipe.objects[index + 2] = {rectangle = true, body = c.MESSAGE, invisible = true, alpha = 0.4, message_index = 2, width = 200, height = 1000, fill_color = {0, 0, 1}, x = 500,  y = 400};
	world_recipe.objects[index + 3] = {rectangle = true, body = c.MESSAGE, invisible = true, alpha = 0.4, message_index = 3, width = 500, height = 700, fill_color = {0, 0, 1}, x = -500,  y = -400};

	return world_recipe;
end

------------------------------------------------------------------

function world_recipes:get(world)

	if (world == world_recipes.BALLOON) then
		return balloon();
	else
		return flowers();
	end
end

return world_recipes;