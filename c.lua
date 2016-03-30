
local c = {};

------------------------------------------------------------------
-- Screen

c.SCREEN_WIDTH  = display.contentWidth;
c.SCREEN_HEIGHT = display.contentHeight;

c.HALF_SCREEN_WIDTH  = c.SCREEN_WIDTH * 0.5;
c.HALF_SCREEN_HEIGHT = c.SCREEN_HEIGHT * 0.5;

------------------------------------------------------------------
-- Debug

c.DEBUG_WITH_GENERATED_DATA = 10;
c.DEBUG_WITH_EVENT 			= 11;

------------------------------------------------------------------
-- Collision and events

c.NONE          = 1;
c.BALLOON       = 2;
c.TREASURE      = 3;
c.WAVE          = 4;
c.ACTIVATOR     = 5;
c.MESSAGE       = 6;

------------------------------------------------------------------
-- Camera

c.SIMPLE 	= 101;
c.BOX    	= 102;

------------------------------------------------------------------

return c;