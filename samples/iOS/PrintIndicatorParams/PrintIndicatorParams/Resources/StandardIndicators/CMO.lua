-- Indicator profile initialization routine
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 9);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("CMO_color", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_CMO_line_name")), core.rgb(0, 0, 255));
    indicator.parameters:addInteger("CMO_width", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_CMO_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("CMO_style", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_CMO_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("CMO_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
local P;
local sc;

local first;
local first_cm;
local source = nil;

-- Streams block
local cmo1 = nil;
local cmo2 = nil;
local CMO = nil;

if ffi then 
    local ffi_source;
    local ffi_CMO;
    local ffi_cmo1;
    local ffi_cmo2;
end
-- Routine
function Prepare()
    P = instance.parameters.P;
    source = instance.source;
    first_cm = source:first() + 1;
    first = first_cm + P;
    sc = 2 / (P + 1);
    local name = profile:id() .. "(" .. source:name() .. ", " .. P .. ")";
    instance:name(name);
    cmo1 = instance:addInternalStream(first_cm, 0);
    cmo2 = instance:addInternalStream(first_cm, 0);
    CMO = instance:addStream("CMO", core.Line, name, "CMO", instance.parameters.CMO_color, first);
    CMO:setWidth(instance.parameters.CMO_width);
    CMO:setStyle(instance.parameters.CMO_style);
    CMO:addLevel(100);
    CMO:addLevel(0);
    CMO:addLevel(-100);
    CMO:setPrecision(2);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_CMO = ffi.cast(pv, CMO.ffi_ptr);
        ffi_cmo1 = ffi.cast(pv, cmo1.ffi_ptr);
        ffi_cmo2 = ffi.cast(pv, cmo2.ffi_ptr);
    end

end


-- Indicator calculation routine
if ffi then

function Update(period)
    indicore3_ffi.outputstreamimpl_set(ffi_cmo1, period, 0);
    indicore3_ffi.outputstreamimpl_set(ffi_cmo2, period, 0);

    if period >= first_cm then
        -- calculate CMO
        local diff;
        diff = indicore3_ffi.stream_getPrice(ffi_source, period) - 
                                             indicore3_ffi.stream_getPrice(ffi_source, period - 1);
        if diff > 0 then
            indicore3_ffi.outputstreamimpl_set(ffi_cmo1, period, diff);
        elseif diff < 0 then
            indicore3_ffi.outputstreamimpl_set(ffi_cmo2, period, -diff);
        end
    end

    if period >= first then
        local p, cmo, s1, s2;
        p = period - P + 1;
        s1 = indicore3_ffi.core_math_sum(ffi_cmo1, p, period);
        s2 = indicore3_ffi.core_math_sum(ffi_cmo2, p, period);
        indicore3_ffi.outputstreamimpl_set(ffi_CMO, period, (s1 - s2) / (s1 + s2) * 100);
    end
end

else

function Update(period)
    cmo1[period] = 0;
    cmo2[period] = 0;

    if period >= first_cm then
        -- calculate CMO
        local diff;
        diff = source[period] - source[period - 1];
        if diff > 0 then
            cmo1[period] = diff;
        elseif diff < 0 then
            cmo2[period] = -diff;
        end
    end

    if period >= first then
        local p, cmo, s1, s2;
        p = period - P + 1;
		s1 = mathex.sum(cmo1, p, period);
        s2 = mathex.sum(cmo2, p, period);
		CMO[period] = (s1 - s2) / (s1 + s2) * 100;
    end
end

end