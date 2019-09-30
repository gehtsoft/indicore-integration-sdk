-- AROON Indicator
-- Developed by Tushar Chande in 1995, Aroon is an indicator system
-- that can be used to determine whether a stock is trending or not and
-- how strong the trend is. "Aroon" means "Dawn's Early Light" in
-- Sanskrit and Chande choose that name for this indicator since it is
-- designed to reveal the beginning of a new trend.
-- The Aroon indicator system consists of two lines, 'Aroon(up)' and
-- 'Aroon(down)'. It takes a single parameter which is the number of time
-- periods to use in the calculation. Aroon(up) is the amount of time (on
-- a percentage basis) that has elapsed between the start of the time
-- period and the point at which the highest price during that time
-- period occurred. If the stock closes at a new high for the given
-- period, Aroon(up) will be +100. For each subsequent period that passes
-- without another new high, Aroon(up) moves down by an amount equal to
-- (1 / # of periods) x 100.
-- Technically, the formula for Aroon(up) is:
-- [[ (# of periods) - (# of periods since highest high during that time) ] / (# of periods) ] x 100--
-- The formula for Aroon(down) is :
-- [[ (# of periods) - (# of periods since lowest low during that time) ] / (# of periods) ] x 100

-- Indicator profile initialization routine
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 25, 3, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUp", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_Up_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_Up_line_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthUP", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_Up_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_Up_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleUP", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_Up_line_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_Up_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleUP", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrDown", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_Down_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_Down_line_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthDOWN", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_Down_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_Down_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleDOWN", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_Down_line_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_Down_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleDOWN", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local firstPeriod;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;

if ffi then 
    local ffi_source;
    local ffi_UP;
    local ffi_DOWN;
end

-- Routine
function Prepare()
    N = instance.parameters.N;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    UP = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.clrUp, firstPeriod)
    UP:setWidth(instance.parameters.widthUP);
    UP:setStyle(instance.parameters.styleUP);
    UP:setPrecision(2);
    DOWN = instance:addStream("DOWN", core.Line, name .. ".DOWN", "DOWN", instance.parameters.clrDown, firstPeriod)
    DOWN:setWidth(instance.parameters.widthDOWN);
    DOWN:setStyle(instance.parameters.styleDOWN);
    DOWN:setPrecision(2);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_UP = ffi.cast(pv, UP.ffi_ptr);
        ffi_DOWN = ffi.cast(pv, DOWN.ffi_ptr);
              
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
    local vmin, pmin;
    local vmax, pmax;
    if period >= firstPeriod then
        vmin, vmax, pmin, pmax = mathex_minmax(ffi_source, period - N + 1, period);
        indicore3_ffi.outputstreamimpl_set(ffi_UP, period, (N - (period - pmax)) / N * 100);
        indicore3_ffi.outputstreamimpl_set(ffi_DOWN, period, (N - (period - pmin)) / N * 100);
    end
end

else

function Update(period)
    local vmin, pmin;
    local vmax, pmax;
    if period >= firstPeriod then
        vmin, vmax, pmin, pmax = mathex.minmax(source, period - N + 1, period);
        UP[period] = (N - (period - pmax)) / N * 100;
        DOWN[period] = (N - (period - pmin)) / N * 100;
    end
end

end