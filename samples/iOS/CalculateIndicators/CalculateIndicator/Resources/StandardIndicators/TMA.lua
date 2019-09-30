-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 4 "Trend Calculations" (page 71-73)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Moving Averages");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 1, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrTMA", resources:get("R_line_color_name"), 
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_TMA_line_name")), core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthTMA", resources:get("R_line_width_name"), 
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_TMA_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleTMA", resources:get("R_line_style_name"), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_TMA_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleTMA", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local wma = nil;
local wmaFirst = nil;

local int;
-- Streams block
local TMA = nil;
local len = 0;
local fract = 0;

if ffi then
    local ffi_source;
    local ffi_output;
end


-- Routine
function Prepare()
    n = instance.parameters.N;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);

    len, fract = math.modf(n / 2);
    len = len + 1;
    wma = instance:addInternalStream(source:first() + len, 0);
    wmaFirst = wma:first();
    first = wmaFirst + len;

    TMA = instance:addStream("TMA", core.Line, name, "TMA", instance.parameters.clrTMA, first)
    TMA:setWidth(instance.parameters.widthTMA);
    TMA:setStyle(instance.parameters.styleTMA);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_tma = ffi.cast(pv, TMA.ffi_ptr);
        ffi_wma = ffi.cast(pv, wma.ffi_ptr);
    end
end

-- Indicator calculation routine
if ffi then

function Update(period)
    if (period >= wmaFirst) then
        indicore3_ffi.outputstreamimpl_set(ffi_wma, 
                                           period, 
                                           indicore3_ffi.core_math_avg(ffi_source, period - len + 1, period));
    end
    if period >= first then
        indicore3_ffi.outputstreamimpl_set(ffi_tma,
                                           period,
                                           indicore3_ffi.core_math_avg(ffi_wma, period - len + 1, period));
    end
end

else

function Update(period)
    if (period >= wmaFirst) then
        wma[period] = mathex.avg(source, period - len + 1, period);
    end
    if period >= first then
        TMA[period] = mathex.avg(wma, period - len + 1, period);
    end
end

end