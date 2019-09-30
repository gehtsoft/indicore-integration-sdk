-- The indicator corresponds to the Commodity Channel Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 8 "Sycle Analisis" (page 209-210)

-- Indicator profile initialization routine
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI", resources:get("R_line_color_name"), 
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_CCI_line_name")), core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthCCI", resources:get("R_line_width_name"), 
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_CCI_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_CCI_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", resources:get("R_overbought_level_name"), resources:get("R_overbought_level_description"), 100, -1000, 1000);
    indicator.parameters:addInteger("oversold", resources:get("R_oversold_level_name"), resources:get("R_oversold_level_description"), -100, -1000, 1000);
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
local tp = nil;

if ffi then
   local ffi_source;
   local ffi_CCI;
end

-- Streams block
local CCI = nil;

-- Routine
function Prepare()
    assert(instance.parameters.oversold < instance.parameters.overbought, resources:get("R_error_bought_bigger_sold"));

    n = instance.parameters.N;
    source = instance.source.typical;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    first = source:first() + n - 1;
    CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.clrCCI, first);
    CCI:setWidth(instance.parameters.widthCCI);
    CCI:setStyle(instance.parameters.styleCCI);
    CCI:setPrecision(2);

    CCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCI:addLevel(0);
    CCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_CCI = ffi.cast(pv, CCI.ffi_ptr);    
    end

end

-- Indicator calculation routine
if ffi then

function Update(period)
    if period >= first then
        local from = period - n + 1;
        local to = period;
        local mean = indicore3_ffi.core_math_avg(ffi_source, from, to);
        local meandev = indicore3_ffi.core_math_meandev(ffi_source, from, to);
	    	    
        if (meandev == 0) then
            indicore3_ffi.outputstreamimpl_set(ffi_CCI, period, 0);
        else
            indicore3_ffi.outputstreamimpl_set(ffi_CCI, 
                                               period, 
                                               (indicore3_ffi.stream_getPrice(ffi_source, period) - mean) / 
                                               (meandev * 0.015));
        end
    end
end

else

function Update(period)
    if period >= first then
        local from = period - n + 1;
        local to = period;
        local mean = mathex.avg(source, from, to);
        local meandev = mathex.meandev(source, from, to);
        		
        if (meandev == 0) then
            CCI[period] = 0;
        else
            CCI[period] = (source[period] - mean) / (meandev * 0.015);
        end
    end
end

end