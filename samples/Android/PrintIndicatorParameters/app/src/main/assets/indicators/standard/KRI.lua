-- There is no formula into Kaufman book and no analog in MetaTrader.
-- http://www.bull-n-bear.ru/technic/?t_analysis=kri
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Oscillators");
    indicator:setTag("AllowAllSources", "y");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrKRI", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_KRI_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_KRI_line_name")), core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthKRI", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_KRI_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_KRI_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleKRI", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_KRI_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_KRI_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleKRI", core.FLAG_LEVEL_STYLE);
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
local KRI = nil;

-- Routine
function Prepare()
    n = instance.parameters.N;
    if instance.source:isBar() then
        source = instance.source.close;
    else
        source = instance.source;
    end
    first = source:first() + n + 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);

    KRI = instance:addStream("KRI", core.Line, name, "KRI", instance.parameters.clrKRI, first)
    KRI:setWidth(instance.parameters.widthKRI);
    KRI:setStyle(instance.parameters.styleKRI);
    local precision = math.max(2, source:getPrecision());
    KRI:setPrecision(precision);
    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_output = ffi.cast(pv, KRI.ffi_ptr);

    end
end

-- Indicator calculation routine

if ffi then

function Update(period)
   if period >= first then
       local mvaValue = indicore3_ffi.core_math_avg(ffi_source, period - n + 1, period);
       indicore3_ffi.outputstreamimpl_set(ffi_output, 
                                          period, 
                                          100 * ( indicore3_ffi.stream_getPrice(ffi_source, period) - mvaValue) / mvaValue);
    end

end

else

function Update(period, mode)
    if period >= first then
        local mvaValue = mathex.avg(source, period - n + 1, period);
        KRI[period] = 100 * (source[period] - mvaValue) / mvaValue;
    end
end

end



