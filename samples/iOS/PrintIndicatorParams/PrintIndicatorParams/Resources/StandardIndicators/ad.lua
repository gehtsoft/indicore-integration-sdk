function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", resources:get("param_Method_name"), resources:get("param_Method_description"), "CI");
    indicator.parameters:addStringAlternative("Method", resources:get("string_alternative_Method_Classic"), "", "CS");
    indicator.parameters:addStringAlternative("Method", resources:get("string_alternative_Method_ClassicIncremental"), "", "CI");
    indicator.parameters:addStringAlternative("Method", resources:get("string_alternative_Method_TradeStation"), "", "TS");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrAD", resources:get("R_line_color_name"), 
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_AD_line_name")), core.rgb(255, 83, 83));
    indicator.parameters:addInteger("widthAD", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_AD_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleAD", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_AD_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleAD", core.FLAG_LEVEL_STYLE);
end

local source;
local o, h, l, c, v;
local first;
local AD;
local Method;

if ffi then
    local ffi_source;
    local ffi_o;
    local ffi_h;
    local ffi_l;
    local ffi_c;
    local ffi_v;
    local ffi_AD;
end

function Prepare()
    source = instance.source;
    o = source.open;
    h = source.high;
    l = source.low;
    c = source.close;
    v = source.volume;
    first = source:first();

    if instance.parameters.Method == "CS" then
        Method = 1;
    elseif instance.parameters.Method == "CI" then
        Method = 2;
    elseif instance.parameters.Method == "TS" then
        Method = 3;
    else
        Method = 2;
    end


    assert(source:supportsVolume(), resources:get("assert_supportsVolume"));

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.Method .. ")";
    instance:name(name);

    AD = instance:addStream("AD", core.Line, name, "AD", instance.parameters.clrAD, first);
    AD:setPrecision(2);
    AD:setWidth(instance.parameters.widthAD);
    AD:setStyle(instance.parameters.styleAD);
    AD:addLevel(0);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_o = ffi.cast(pv, o.ffi_ptr);
        ffi_h = ffi.cast(pv, h.ffi_ptr);
        ffi_l = ffi.cast(pv, l.ffi_ptr);
        ffi_c = ffi.cast(pv, c.ffi_ptr);
        ffi_v = ffi.cast(pv, v.ffi_ptr);
        ffi_AD = ffi.cast(pv, AD.ffi_ptr);
    end

end

if ffi then

function Update(period)
    if period >= first then
        if Method == 1 or Method == 2 then
            -- classic
            local oo = indicore3_ffi.stream_getPrice(ffi_o,period)
            local hh = indicore3_ffi.stream_getPrice(ffi_h, period);
            local ll = indicore3_ffi.stream_getPrice(ffi_l, period);
            local cc = indicore3_ffi.stream_getPrice(ffi_c,period);
            if (hh - ll) == 0 then
                indicore3_ffi.outputstreamimpl_set(ffi_AD, period, 0);
            else
                indicore3_ffi.outputstreamimpl_set(ffi_AD, 
                                                   period,
                                                    ((cc - ll) - (hh - cc)) / (hh - ll) * indicore3_ffi.stream_getPrice(ffi_v, period));
            end
        else
        -- TS (method == 3)
            indicore3_ffi.outputstreamimpl_set(ffi_AD,
                                               period,
                                               (indicore3_ffi.stream_getPrice(ffi_c, period) -
                                                indicore3_ffi.stream_getPrice(ffi_o, period)) / 
                                                (indicore3_ffi.stream_getPrice(ffi_h,period) -
                                                indicore3_ffi.stream_getPrice(ffi_l, period)) * 
                                                indicore3_ffi.stream_getPrice(ffi_v, period));
        end

        if period >= first + 1 and Method == 2 or Method == 3 then
            indicore3_ffi.outputstreamimpl_set(ffi_AD,
                                               period, 
                                               indicore3_ffi.stream_getPrice(ffi_AD, period) + 
                                               indicore3_ffi.stream_getPrice(ffi_AD, period - 1));
       end
    end	
end

else

function Update(period, mode)
    if period >= first then
        if Method == 1 or Method == 2 then
            -- classic
            if h[period] - l[period] == 0 then
                AD[period] = 0;
            else
                AD[period] = ((c[period] - l[period]) - (h[period] - c[period])) / (h[period] - l[period]) * v[period];
            end
        else
            -- TS (method == 3)
            if h[period] - l[period] == 0 then
                AD[period] = 0;
            else
                AD[period] = (c[period] - o[period]) / (h[period] - l[period]) * v[period];
            end
        end

        if period >= first + 1 and Method == 2 or Method == 3 then
            AD[period] = AD[period] + AD[period - 1];
        end
    end
end

end
