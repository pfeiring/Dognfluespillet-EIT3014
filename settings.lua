
local settings = {};

------------------------------------------------------------------

local c = require('c');

------------------------------------------------------------------
-- Assets

settings.IMAGE_FOLDER       = 'images/';

------------------------------------------------------------------
-- Debug

settings.DEBUG 				= false;
settings.DEBUG_MODE 		= c.DEBUG_WITH_EVENT;

------------------------------------------------------------------
-- Basics

settings.GAME_DURATION_IN_MINUTES      	= 15;           -- Minutes

settings.FLY_SPEED 						= 2;

------------------------------------------------------------------
-- Location

settings.LOCATION_TIME_TRESHOLD      	= 5;
settings.LOCATION_DISTANCE_THRESHOLD   	= 0.00005;
settings.LOCATION_STEP_SIZE            	= 100;

------------------------------------------------------------------
-- Happy meter

settings.HAPPY_METER_START_SCALE 		= 0.2;

settings.HAPPY_METER_UPDATE_BALLOON 	= 0.1;
settings.HAPPY_METER_UPDATE_WAVE 		= 0.05;
settings.HAPPY_METER_UPDATE_ACTIVATOR 	= 0.1;

------------------------------------------------------------------
-- Camera

settings.CAMERA_MODE 			  = c.BOX;
settings.CAMERA_TARGET_POSITION_X = c.HALF_SCREEN_WIDTH;
settings.CAMERA_TARGET_POSITION_Y = c.HALF_SCREEN_HEIGHT;

return settings;