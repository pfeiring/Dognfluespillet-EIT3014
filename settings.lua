
local settings = {};

------------------------------------------------------------------

local c = require('c');

------------------------------------------------------------------
-- Assets

settings.IMAGE_FOLDER       = 'images/';
settings.VIDEO_FOLDER		= 'videos/';

------------------------------------------------------------------
-- Debug

settings.DEBUG 				= false;
settings.DEBUG_MODE 		= c.DEBUG_WITH_EVENT;

------------------------------------------------------------------
-- Basics

settings.GAME_DURATION_IN_MINUTES      	= 10;           -- Minutes

settings.FLY_SPEED 						= 10;

------------------------------------------------------------------
-- Location

settings.LOCATION_TIME_TRESHOLD      	= 1;
settings.LOCATION_DISTANCE_THRESHOLD   	= 0.00005;
settings.LOCATION_STEP_SIZE            	= 80;

------------------------------------------------------------------
-- Happy meter

settings.HAPPY_METER_START_SCALE 		= 0.5;

settings.HAPPY_METER_UPDATE_BALLOON 	= 0.04;
settings.HAPPY_METER_UPDATE_WAVE 		= 0.02;
settings.HAPPY_METER_UPDATE_ACTIVATOR 	= 0.04;
settings.HAPPY_METER_UPDATE_PORTAL 		= 0.2;

return settings;