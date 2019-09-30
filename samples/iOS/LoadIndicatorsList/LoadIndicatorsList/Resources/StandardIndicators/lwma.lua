-- The indicator corresponds to the Moving Average indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 4 "Trend Calculations" (page 68-70)

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
    indicator.parameters:addColor("clrLWMA", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_LWMA_line_name")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLWMA", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_LWMA_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleLWMA", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_LWMA_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleLWMA", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local firstPeriod;
local source = nil;

if ffi then
    local ffi_source;
    local ffi_output;
end

-- Streams block
local LWMA = nil;

-- Routine
function Prepare()
    N = instance.parameters.N;
    source = instance.source;
    firstPeriod = source:first() + N - 1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
  
    LWMA = instance:addStream("LWMA", core.Line, name, "LWMA", instance.parameters.clrLWMA, firstPeriod)
    LWMA:setWidth(instance.parameters.widthLWMA);
    LWMA:setStyle(instance.parameters.styleLWMA);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_output = ffi.cast(pv, LWMA.ffi_ptr);
    end
end

-- Indicator calculation routine
if ffi then

function Update(period)
    if period >= firstPeriod then
        indicore3_ffi.outputstreamimpl_set(ffi_output,
                                           period,
                                           indicore3_ffi.core_math_lwma(ffi_source, period - N + 1, period));
    end
end

else

function Update(period)
    if period >= firstPeriod then
        LWMA[period] = mathex.lwma(source, period - N + 1, period);
    end
end

end



