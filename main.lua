
local c 			= require('c');
local world_recipes = require('world_recipes');
local composer 		= require('composer');

------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar);
display.setDefault('background', 1, 1, 1);

------------------------------------------------------------------

local goto_options = {
	params 	= {
		world_name = c.WORLD_BALLOON
	}
}

composer.gotoScene('scene_world', goto_options);