
local c = {};

------------------------------------------------------------------
-- Screen

c.SCREEN_WIDTH  = display.contentWidth;
c.SCREEN_HEIGHT = display.contentHeight;

c.HALF_SCREEN_WIDTH  = c.SCREEN_WIDTH * 0.5;
c.HALF_SCREEN_HEIGHT = c.SCREEN_HEIGHT * 0.5;

------------------------------------------------------------------
-- Debug

c.DEBUG_WITH_GENERATED_DATA = 'debug_with_generated_data';
c.DEBUG_WITH_EVENT 			= 'debug_with_event';

------------------------------------------------------------------
-- World

c.WORLD_BALLOON = 'world_balloon';
c.WORLD_FLOWERS = 'world_flowers';

------------------------------------------------------------------
-- Collision and events

c.NONE          = 'none';
c.BALLOON       = 'balloon';
c.TREASURE      = 'treasure';
c.WAVE          = 'wave';
c.ACTIVATOR     = 'activator';
c.MESSAGE       = 'message';
c.PORTAL        = 'portal';
c.CARNIV		= 'carniv';
c.LAMP			= 'lamp';

------------------------------------------------------------------
-- Camera

c.SIMPLE 	= 'simple';
c.BOX    	= 'box';

------------------------------------------------------------------

return c;