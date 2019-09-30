-- The indicator corresponds to the Larry Williams' Percent Range indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 143)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRLW", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_RLW_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRLW", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_RLW_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleRLW", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_RLW_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleRLW", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", resources:get("R_overbought_level_name"), resources:get("R_overbought_level_description"), -20, -100, 0);
    indicator.parameters:addInteger("oversold", resources:get("R_oversold_level_name"), resources:get("R_oversold_level_description"), -80, -100, 0);
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

if ffi then 
    local ffi_source;
    local ffi_RLW;
    local ffi_close;
end


-- Streams block
local RLW = nil;

-- Routine
function Prepare()
    assert(instance.parameters.oversold < instance.parameters.overbought, resources:get("R_error_bought_bigger_sold"));

    n = instance.parameters.N;
    source = instance.source;
    first = source:first() + n - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    RLW = instance:addStream("RLW", core.Line, name, "%R", instance.parameters.clrRLW, first)
    RLW:setWidth(instance.parameters.widthRLW);
    RLW:setStyle(instance.parameters.styleRLW);
    RLW:setPrecision(2);

    RLW:addLevel(0);
    RLW:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(-100);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_RLW = ffi.cast(pv, RLW.ffi_ptr);
        ffi_close = ffi.cast(pv, source.close.ffi_ptr);

    end
end

-- Indicator calculation routine
if ffi then

function mathex_minmax(stream, from, to)

    local maxVal = -1.7976931348623158e+308
    local minVal = 1.7976931348623158e+308

    local maxPos = -1;
    local minPos = -1;

    if indicore3_ffi.stream_isBar(stream) == true then
        for i = from , to, 1  do
           local high = indicore3_ffi.barstream_getHigh(stream, i);
           local low = indicore3_ffi.barstream_getLow(stream, i);
           if maxVal < high then
               maxVal = high;
               maxPos = i;
           end
           if  minVal > low then
               minVal = low;
               minPos = i;
           end     
        end
    else
        for i = from , to, 1 do
            local t= indicore3_ffi.stream_getPrice(stream, i);
            if maxVal < t then
                maxVal = t;
                maxPos = i;
            end
            if minVal > t then
                minVal = t;
                minPos = i;
            end
        end
    end
    return minVal, maxVal, minPos, maxPos 
end

function Update(period)
    if period >= first then
        local from = period - n + 1;
        low, high = mathex_minmax(ffi_source, from, period);
        local diff = high - low;
        if (diff == 0) then
            indicore3_ffi.outputstreamimpl_set(ffi_RLW, period, 0);
        else
            indicore3_ffi.outputstreamimpl_set(ffi_RLW, 
                                               period, 
                                               (-100) * (high - indicore3_ffi.stream_getPrice(ffi_close, period)) / diff);
        end
    end
end

else

function Update(period)
    if period >= first then
        local from = period - n + 1;
        low, high = mathex.minmax(source, from, period);
        local diff = high - low;
        if (diff == 0) then
            RLW[period] = 0;
        else
            RLW[period] = (-100) * (high - source.close[period]) / diff;
        end
    end
end

end
