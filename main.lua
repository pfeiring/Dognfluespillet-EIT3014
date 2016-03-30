
local c 			= require('c');
local world_recipes = require('world_recipes');
local composer 		= require('composer');

------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar);
display.setDefault('background', 1, 1, 1);

------------------------------------------------------------------

local goto_options = {
	effect 	= 'fade',
	time  	= 500,
	params 	= {
		world_name = c.WORLD_BALLOON
	}
}

composer.gotoScene('world', goto_options);