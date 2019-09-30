-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 3 "Regression Analysis" (page 37-40)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrLinReg", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;

if ffi then
    local ffi_source;
    local ffi_output;
end

-- Streams block
local Regression = nil;

-- Routine
function Prepare()
    n = instance.parameters.N;
    source = instance.source;
    first = source:first() + n;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    Regression = instance:addStream("Regression", core.Line, name, "Regression", instance.parameters.clrLinReg, first)
    Regression:setWidth(instance.parameters.widthLinReg);
    Regression:setStyle(instance.parameters.styleLinReg);
    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_output = ffi.cast(pv, Regression.ffi_ptr);
    end
end

-- Indicator calculation routine
if ffi then

function Update(period)
    if period >= first then
        indicore3_ffi.outputstreamimpl_set(ffi_output, 
                                           period, 
                                           indicore3_ffi.core_math_lreg(ffi_source, 
                                                                        indicore3_ffi.core_math_rangeto(period, n),
                                                                        period));
    end
end

else

function Update(period)
    if period >= first then
        Regression[period] = mathex.lreg(source, core.rangeTo(period, n));
    end
end

end