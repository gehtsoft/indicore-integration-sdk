-- The indicator corresponds to the Relative Strength Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 133-134)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRSI", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_RSI_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRSI", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_RSI_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleRSI", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_RSI_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleRSI", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", resources:get("R_overbought_level_name"), resources:get("R_overbought_level_description"), 70, 0, 100);
    indicator.parameters:addInteger("oversold", resources:get("R_oversold_level_name"), resources:get("R_oversold_level_description"), 30, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_overbought_oversold_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_overbought_oversold_description")), 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_overbought_oversold_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_overbought_oversold_description")), core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_overbought_oversold_name")), 
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_overbought_oversold_description")), core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local pos = nil;
local neg = nil;

-- Streams block
local RSI = nil;

-- Routine
function Prepare()
    assert(instance.parameters.oversold < instance.parameters.overbought, resources:get("R_error_bought_bigger_sold"));

    n = instance.parameters.N;
    source = instance.source;
    first = source:first() + n;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);

    pos = instance:addInternalStream(0, 0);
    neg = instance:addInternalStream(0, 0);

    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.clrRSI, first);
    RSI:setWidth(instance.parameters.widthRSI);
    RSI:setStyle(instance.parameters.styleRSI);
    RSI:setPrecision(2);
    
    RSI:addLevel(0);
    RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RSI:addLevel(50);
    RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    RSI:addLevel(100);
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local i = 0;
        local sump = 0;
        local sumn = 0;
        local positive = 0;
        local negative = 0;
        local diff = 0;
        if (period == first) then
            for i = period - n + 1, period do
                diff = source[i] - source[i - 1];
                if (diff >= 0) then
                    sump = sump + diff;
                else
                    sumn = sumn - diff;
                end
            end
            positive = sump / n;
            negative = sumn / n;
        else
            diff = source[period] - source[period - 1];
            if (diff > 0) then 
                sump = diff;
            else
                sumn = -diff;
            end
            positive = (pos[period - 1] * (n - 1) + sump) / n;
            negative = (neg[period - 1] * (n - 1) + sumn) / n;
        end
        pos[period] = positive;
        neg[period] = negative;
        if (negative == 0) then
            RSI[period] = 0;
        else
            RSI[period] = 100 - (100 / (1 + positive / negative));
        end
    end
end