
local UI = {};

------------------------------------------------------------------

local c 		= require('c');
local settings 	= require('settings');

------------------------------------------------------------------

UI.background_left = {};
UI.background_right = {};

UI.clock = {};

UI.happy_meter_background = {};
UI.happy_meter = {};

UI.compass = {};

UI.message = {};
UI.message_background = {};
UI.message_text = {};

------------------------------------------------------------------

function UI:construct_backgrounds()

	UI.background_left = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_background.png', 176, 176);
    UI.background_left.x = (176 / 2);
    UI.background_left.y = (176 / 2);

    UI.background_right = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_background.png', 176, 176);
    UI.background_right.x = c.SCREEN_WIDTH - (176 / 2);
    UI.background_right.y = (176 / 2);
end

------------------------------------------------------------------
-- Clock

function UI:construct_clock()

	UI.clock = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_clock.png', 176, 176);
    UI.clock.x = UI.background_left.x;
    UI.clock.y = UI.background_left.y;
    UI.clock.yScale = 1;

    if (not UI.clock_start_time) then
    	UI.clock_start_time = os.time();
    end
end

function UI:update_clock()

    local current_time = os.time();
    local elapsed_time = current_time - UI.clock_start_time;
    
    local timed_out;

    if (elapsed_time >= (settings.GAME_DURATION_IN_MINUTES * 60)) then
        UI.clock.rotation = 360;
        UI.clock.isVisible = false;

        timed_out = true;
    else
        UI.clock.rotation = 360 * (elapsed_time / (settings.GAME_DURATION_IN_MINUTES * 60));

        timed_out = false;
    end

    return timed_out;
end

function UI:reset_clock()
	UI.clock_start_time = nil;
end

------------------------------------------------------------------
-- Happy meter

function UI:construct_happy_meter()

	UI.happy_meter_background = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_happy_meter_background.png', 176, 176);
    UI.happy_meter_background.x = UI.background_left.x;
    UI.happy_meter_background.y = UI.background_left.y;

    ------------------------------------------------------------------

    UI.happy_meter = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_happy_meter_2.png', 76, 76);
    UI.happy_meter.x = UI.background_left.x;
    UI.happy_meter.y = UI.background_left.y;
    UI.happy_meter.value = settings.HAPPY_METER_START_SCALE;

    UI.happy_meter_mask = graphics.newMask(settings.IMAGE_FOLDER .. 'UI_happy_meter_mask.png');
    UI.happy_meter:setMask(UI.happy_meter_mask);

    UI.happy_meter.maskY = 76 * (1 - UI.happy_meter.value);
end

function UI:update_happy_meter(increase)

    UI.happy_meter.value = math.min(1, UI.happy_meter.value + increase);
    UI.happy_meter.maskY = 76 * (1 - UI.happy_meter.value);
end

------------------------------------------------------------------
-- Compass

function UI:construct_compass()

	UI.compass = display.newImageRect(settings.IMAGE_FOLDER .. 'UI_compass.png', 176, 176);
    UI.compass.x = UI.background_right.x;
    UI.compass.y = UI.background_right.y;
end

------------------------------------------------------------------
-- Messages

function UI:construct_message_box(world_recipe_messages)

    UI.message.index = -1;
    UI.message.entry = -1;

    UI.message_background = display.newImageRect(settings.IMAGE_FOLDER .. 'message_background.png', 640, 640);
    UI.message_background.x = c.HALF_SCREEN_WIDTH;
    UI.message_background.y = c.HALF_SCREEN_HEIGHT + 350;
    UI.message_background.isVisible = false;

    UI.message_text = display.newText({
            text = '',
            x = UI.message_background.x,
            y = UI.message_background.y + 10,
            width = 540,
            font = 'PTMono-Regular',
            fontSize = 32,
            align = 'center'});
    UI.message_text:setFillColor(0);
    UI.message_text.isVisible = false;

    UI.message.world_recipe_messages = world_recipe_messages;
end

function UI.message_event(event)

    UI.message.entry = UI.message.entry + 1;

    if (UI.message.index >= 1 and #UI.message.world_recipe_messages[UI.message.index] >= UI.message.entry) then

        local message = UI.message.world_recipe_messages[UI.message.index];
        local message_text = message[UI.message.entry];

        UI.message_text.text = message_text;
    else
        UI.message.index = -1;
        UI.message.entry = -1;

        UI.message_background.isVisible = false;
        UI.message_text.isVisible = false;
    end

    return true;
end

function UI:show_message(message_index)

    UI.message.index = message_index;
    UI.message.entry = 1;

    local message = UI.message.world_recipe_messages[UI.message.index];
    local message_text = message[UI.message.entry];

    UI.message_text.text = message_text;

    UI.message_background.isVisible = true;
    UI.message_text.isVisible = true;
end

return UI;
