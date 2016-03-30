
local settings = {};

------------------------------------------------------------------

local c = require('c');

------------------------------------------------------------------
-- Assets

settings.IMAGE_FOLDER       = 'images/';

------------------------------------------------------------------
-- Debug

settings.DEBUG 				= true;
settings.DEBUG_MODE 		= c.DEBUG_WITH_EVENT;

------------------------------------------------------------------
-- Basics

settings.LOCATION_TIME_TRESHOLD      	= 1;
settings.LOCATION_DISTANCE_THRESHOLD   	= 0.00015;
settings.LOCATION_STEP_SIZE            	= 100;

settings.GAME_DURATION_IN_MINUTES      	= 1;               -- Minutes

------------------------------------------------------------------
-- Camera

settings.CAMERA_MODE 			  = c.BOX;
settings.CAMERA_TARGET_POSITION_X = c.HALF_SCREEN_WIDTH;
settings.CAMERA_TARGET_POSITION_Y = c.HALF_SCREEN_HEIGHT;

return settings;