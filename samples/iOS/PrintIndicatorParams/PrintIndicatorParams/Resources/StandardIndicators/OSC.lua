-- There is no formula into Kaufman book and no analog in MetaTrader.
-- http://www.bull-n-bear.ru/technic/?t_analysis=osc
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");
    indicator:setTag("AllowAllSources", "y");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("M", resources:get("param_M_name"), resources:get("param_M_description"), 7, 2, 1000);
    indicator.parameters:addInteger("N", resources:get("param_N_name"), resources:get("param_N_description"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("OSC", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_OSC_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthOSC", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_OSC_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleOSC", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_OSC_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleOSC", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local m;

local first;
local source = nil;
local mvaN = nil;
local mvaM = nil;

if ffi then
    local ffi_source;
    local ffi_output;
end

-- Streams block
local OSC = nil;

-- Routine
function Prepare()
    n = instance.parameters.N;
    m = instance.parameters.M;
    if instance.source:isBar() then
        source = instance.source.close;
    else
        source = instance.source;
    end

    first = math.max(m,n) + source:first() - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ", " .. m .. ")";
    instance:name(name);
    OSC = instance:addStream("OSC", core.Line, name, "OSC", instance.parameters.OSC, first)
    OSC:setWidth(instance.parameters.widthOSC);
    OSC:setStyle(instance.parameters.styleOSC);
    local precision = math.max(2, source:getPrecision());
    OSC:setPrecision(precision);

     if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_output = ffi.cast(pv, OSC.ffi_ptr);
    end
end

-- Indicator calculation routine
if ffi then

function Update(period, mode)
    if period >= first then
        local mMvaN = indicore3_ffi.core_math_avg(ffi_source, period - n + 1, period);
        local mMvaM = indicore3_ffi.core_math_avg(ffi_source, period - m + 1, period);
        indicore3_ffi.outputstreamimpl_set (ffi_output, period, mMvaM - mMvaN);
    end
end

else

function Update(period, mode)
    if period >= first then
        local mMvaN = mathex.avg(source, period - n + 1, period);
        local mMvaM = mathex.avg(source, period - m + 1, period);
        OSC[period] = mMvaM - mMvaN;
    end
end

end