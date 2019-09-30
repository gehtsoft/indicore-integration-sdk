-- Indicator profile initialization routine
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Moving Averages");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P", resources:get("R_number_of_periods_name"),resources:get("R_number_of_periods_desciption"), 9, 1, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("V_color", resources:get("R_line_color_name"), 
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_VIDYA_line_name")), core.rgb(0, 0, 255));
    indicator.parameters:addInteger("V_width", resources:get("R_line_width_name"), 
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_VIDYA_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("V_style", resources:get("R_line_style_name"), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_VIDYA_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("V_style", core.FLAG_LEVEL_STYLE);
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
local V = nil;

if ffi then 
    local ffi_source;
    local ffi_cmo1;
    local ffi_cmo2;
    local ffi_V;
    local int;
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
    V = instance:addStream("V", core.Line, name, "V", instance.parameters.V_color, first);
    V:setWidth(instance.parameters.V_width);
    V:setStyle(instance.parameters.V_style);

    if ffi then
        -- following two lines are critcally important for the performance. comment and see how FFI will
        -- work even slover than a regular Lua code :-)
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_cmo1 = ffi.cast(pv, cmo1.ffi_ptr);
        ffi_cmo2 = ffi.cast(pv, cmo2.ffi_ptr);
        ffi_V = ffi.cast(pv, V.ffi_ptr);

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
               indicore3_ffi.stream_getPrice(ffi_source,period - 1);
        if diff > 0 then
            indicore3_ffi.outputstreamimpl_set(ffi_cmo1, period, diff);
        elseif diff < 0 then
            indicore3_ffi.outputstreamimpl_set(ffi_cmo2, period, -diff);
        end
    end

    if period == first then
        indicore3_ffi.outputstreamimpl_set(ffi_V, 
                                           period,
                                           indicore3_ffi.stream_getPrice(ffi_source, period));
    elseif period > first then
        local p, cmo, s1, s2, s12summ;
        p = period - P + 1;
        s1 = indicore3_ffi.core_math_sum(ffi_cmo1, p, period);
        s2 = indicore3_ffi.core_math_sum(ffi_cmo2, p, period);
        s12summ = s1 + s2;
        if (s12summ ~= 0) then
            local abss1s2 = (s1 - s2)/ s12summ;

            if abss1s2 < 0 then
                abss1s2 = -abss1s2;
            end

            cmo = abss1s2;
        else
            cmo = 0;
        end
        indicore3_ffi.outputstreamimpl_set(ffi_V,
                                           period,
                                           sc * cmo * indicore3_ffi.stream_getPrice(ffi_source, period) +
                                           (1 - sc * cmo) * indicore3_ffi.stream_getPrice(ffi_V, period - 1));
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

    if period == first then
        V[period] = source[period];
    elseif period > first then
        local p, cmo, s1, s2, s12summ;
        p = period - P + 1;
        s1 = mathex.sum(cmo1, p, period);
        s2 = mathex.sum(cmo2, p, period);
        s12summ = s1 + s2;
        if (s12summ ~= 0) then
            cmo = math.abs((s1 - s2) / s12summ);
        else
            cmo = 0;
        end
        V[period] = sc * cmo * source[period] + (1 - sc * cmo) * V[period - 1];
    end
end

end
