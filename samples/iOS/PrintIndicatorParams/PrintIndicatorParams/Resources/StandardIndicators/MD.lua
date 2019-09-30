-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 17 "Adaptive Techniques" (page 441)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
    indicator:setTag("AllowAllSources", "y");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrMD", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_MD_line_name")), core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthMD", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_MD_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleMD", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_MD_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleMD", core.FLAG_LEVEL_STYLE);
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
local MD = nil;

-- Routine
function Prepare()
    n = instance.parameters.N;
    if instance.source:isBar() then
        source = instance.source.close;
    else
        source = instance.source;
    end
    first = source:first() + 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    MD = instance:addStream("MD", core.Line, name, "MD", instance.parameters.clrMD, first)
    MD:setWidth(instance.parameters.widthMD);
    MD:setStyle(instance.parameters.styleMD);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_output = ffi.cast(pv, MD.ffi_ptr);

    end
end

-- Indicator calculation routine
if ffi then

function Update(period)
    if period >= first then
        local value = 0;
        local closePeriod = indicore3_ffi.stream_getPrice(ffi_source, period);
        if (period == first) then
            value = closePeriod;
        else
            value = indicore3_ffi.stream_getPrice(ffi_output, period - 1);
        end
            indicore3_ffi.outputstreamimpl_set(ffi_output, 
                                               period, 
                                               value + (closePeriod - value) / 
                                               (0.6 * n * ((closePeriod / value) ^ 4)));
    end
end

else

function Update(period)
    if period >= first then
        local value = 0;
        local closePeriod = source[period];
        if (period == first) then
            value = closePeriod;
        else
            value = MD[period - 1];
        end
            MD[period] = value + (closePeriod - value) / (0.6 * n * ((closePeriod / value) ^ 4));
    end
end

end