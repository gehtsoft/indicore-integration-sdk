-- The indicator corresponds to the Envelopes indicator in MetaTrader.

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Channels");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 7, 1, 1000);
    indicator.parameters:addDouble("Upper", resources:get("param_Upper_name"), resources:get("param_Upper_description"), 0.5, 0, 10.);
    indicator.parameters:addDouble("Lower", resources:get("param_Lower_name"), resources:get("param_Lower_description"), 0.5, 0, 10.);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ME1", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_ME1_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_ME1_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthME1", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_ME1_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_ME1_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleME1", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_ME1_line_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_ME1_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleME1", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("ME2", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_ME2_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_ME2_line_name")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthME2", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_ME2_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_ME2_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleME2", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_ME2_line_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_ME2_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleME2", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local upper;
local lower;

local first;
local source = nil;
local mva = nil;

if ffi then
    local ffi_source;
    local ffi_output1;
    local ffi_output2;
end

-- Streams block
local ME1 = nil;
local ME2 = nil;

-- Routine
function Prepare()
    n = instance.parameters.N;
    upper = instance.parameters.Upper;
    lower = instance.parameters.Lower;
    source = instance.source;
    first = source:first() + n - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ", " .. upper .. ", " .. lower .. ")";
    instance:name(name);
    ME1 = instance:addStream("ME1", core.Line, name .. ".ME1", "ME1", instance.parameters.ME1, first)
    ME1:setWidth(instance.parameters.widthME1);
    ME1:setStyle(instance.parameters.styleME1);
    ME2 = instance:addStream("ME2", core.Line, name .. ".ME2", "ME2", instance.parameters.ME2, first)
    ME2:setWidth(instance.parameters.widthME2);
    ME2:setStyle(instance.parameters.styleME2);


    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_output1 = ffi.cast(pv, ME1.ffi_ptr);
        ffi_output2 = ffi.cast(pv, ME2.ffi_ptr);
    end
end

-- Indicator calculation routine
if ffi then

function Update(period, mode)
    if period >= first then
        local mvaValue = indicore3_ffi.core_math_avg(ffi_source, period - n + 1, period);
        indicore3_ffi.outputstreamimpl_set(ffi_output1, period, mvaValue * (1 + upper / 100));
        indicore3_ffi.outputstreamimpl_set(ffi_output2, period, mvaValue * (1 - lower / 100));
    end
end

else

function Update(period, mode)
    if period >= first then
        local mvaValue = mathex.avg(source, period - n + 1, period);
        ME1[period] = mvaValue * (1 + upper / 100);
        ME2[period] = mvaValue * (1 - lower / 100);
    end
end

end



