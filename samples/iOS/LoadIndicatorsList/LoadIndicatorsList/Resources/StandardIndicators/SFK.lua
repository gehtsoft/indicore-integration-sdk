-- The indicator corresponds to the Stochastic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 135-137)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", resources:get("param_K_name"), resources:get("param_K_description"), 5, 2, 1000);
    indicator.parameters:addInteger("D", resources:get("param_D_name"), resources:get("param_D_description"), 5, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_K_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_K_line_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthFirst", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_K_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_K_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleFirst", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_K_line_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_K_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirst", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSecond", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_D_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_D_line_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSecond", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_D_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_D_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleSecond", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_D_line_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_D_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleSecond", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", resources:get("R_overbought_level_name"), resources:get("R_overbought_level_description"), 80, 0, 100);
    indicator.parameters:addInteger("oversold", resources:get("R_oversold_level_name"), resources:get("R_oversold_level_description"), 20, 0, 100);
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
local k;
local d;

local source = nil;
local mins = nil;
local maxes = nil;
local mva = nil;
local kFirst = nil;
local dFirst = nil;

if ffi then 
    local ffi_source;
    local ffi_K;
    local ffi_D;
    local ffi_source_close;
end

-- Streams block
local K = nil;
local D = nil;

-- Routine
function Prepare()
    assert(instance.parameters.oversold < instance.parameters.overbought, resources:get("R_error_bought_bigger_sold"));

    k = instance.parameters.K;
    d = instance.parameters.D;
    source = instance.source;

    mins = instance:addInternalStream(source:first() + k, 0);
    maxes = instance:addInternalStream(source:first() + k, 0);

    local name = profile:id() .. "(" .. source:name() .. ", " .. k .. ", " .. d .. ")";
    instance:name(name);
    K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, mins:first());
    K:setWidth(instance.parameters.widthFirst);
    K:setStyle(instance.parameters.styleFirst);
    K:setPrecision(2);

    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond, K:first() + d - 1);
    D:setWidth(instance.parameters.widthSecond);
    D:setStyle(instance.parameters.styleSecond);
    D:setPrecision(2);
    kFirst = K:first();
    dFirst = D:first();

    D:addLevel(0);
    D:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    D:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    D:addLevel(100);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_K = ffi.cast(pv, K.ffi_ptr);
        ffi_D = ffi.cast(pv, D.ffi_ptr);
        ffi_source_close = ffi.cast(pv, source.close.ffi_ptr);
        ffi_mins = ffi.cast(pv, mins.ffi_ptr);
        ffi_maxes = ffi.cast(pv, maxes.ffi_ptr);
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

function Update(period, mode)
    if period >= kFirst then
        local minLow, minHigh;
        minLow, maxHigh = mathex_minmax(ffi_source, period - k + 1, period);
        indicore3_ffi.outputstreamimpl_set(ffi_mins, 
                                           period, 
                                           indicore3_ffi.stream_getPrice(ffi_source_close, period) - minLow);
        indicore3_ffi.outputstreamimpl_set(ffi_maxes, period, maxHigh - minLow);
        if indicore3_ffi.stream_getPrice(ffi_maxes, period) > 0 then
            indicore3_ffi.outputstreamimpl_set(ffi_K, 
                                               period, 
                                               indicore3_ffi.stream_getPrice(ffi_mins, period) /
                                               indicore3_ffi.stream_getPrice(ffi_maxes, period) * 100);
        else
            indicore3_ffi.outputstreamimpl_set(ffi_K, period, 50);
        end
    end
    if period >= dFirst then
        indicore3_ffi.outputstreamimpl_set(ffi_D,
                                           period, 
                                           indicore3_ffi.core_math_avg(ffi_K, period - d + 1, period));
    end
    
end

else

function Update(period, mode)
    if period >= kFirst then
        local minLow, minHigh;
        minLow, maxHigh = mathex.minmax(source, period - k + 1, period);
        mins[period] = source.close[period] - minLow;
        maxes[period] = maxHigh - minLow;
        if maxes[period] > 0 then
            K[period] = mins[period] / maxes[period] * 100;
        else
            K[period] = 50;
        end
    end
    if period >= dFirst then
        D[period] = mathex.avg(K, period - d + 1, period);
    end
end

end