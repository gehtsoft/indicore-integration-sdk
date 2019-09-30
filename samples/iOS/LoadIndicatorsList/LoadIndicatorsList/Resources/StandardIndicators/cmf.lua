function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 21, 1, 1000);
    indicator.parameters:addString("ADMethod", resources:get("param_ADMethod_name"), resources:get("param_ADMethod_description"), "CI");
    indicator.parameters:addStringAlternative("ADMethod", resources:get("string_alternative_ADMethod_Classic"), "", "CS");
    indicator.parameters:addStringAlternative("ADMethod", resources:get("string_alternative_ADMethod_ClassicIncremental"), "", "CI");
    indicator.parameters:addStringAlternative("ADMethod", resources:get("string_alternative_ADMethod_TradeStation"), "", "TS");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Display", resources:get("param_Display_name"), resources:get("param_Display_description"), "L");
    indicator.parameters:addStringAlternative("Display", resources:get("string_alternative_Display_Line"), "", "L");
    indicator.parameters:addStringAlternative("Display", resources:get("string_alternative_Display_Histogram"), "", "H");
    indicator.parameters:addColor("clrCMF", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_CHF_line_desc")), core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthCMF", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_CHF_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleCMF", resources:get("R_line_style_name"), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_CHF_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleCMF", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("clrHU", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_HU_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_HU_line_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrHD", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_HD_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_HD_line_desc")), core.rgb(255, 0, 0));
end

local first;
local N;
local AD;
local line;
local CMF;
local U, D;

if ffi then
    local ffi_source;
    local ffi_CMF;
    local ffi_volume;
    local ffi_AD;
    local ffi_AD_DATA;
    local ffi_AD;
end

function Prepare()
    source = instance.source;

    assert(source:supportsVolume(), resources:get("assert_hasVolume"));

    assert(core.indicators:findIndicator("AD") ~= nil, resources:get("assert_ADinstalled"));
    N = instance.parameters.N;

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.N;
    name = name .. ",A/D(" .. instance.parameters.ADMethod .. "))";
    instance:name(name);

    AD = core.indicators:create("AD", source, instance.parameters.ADMethod);

    first = math.max(AD.DATA:first() + N, source:first() + N);
    
    local mode;
    if instance.parameters.Display == "L" then
        mode = core.Line;
        line = true;
    else
        mode = core.Bar;
        line = false;
    end


    CMF = instance:addStream("CMF", mode, name, "CMF", instance.parameters.clrCMF, first);
    CMF:setPrecision(4);
    CMF:setWidth(instance.parameters.widthCMF);
    CMF:setStyle(instance.parameters.styleCMF);
    CMF:addLevel(0);

    U = instance.parameters.clrHU;
    D = instance.parameters.clrHD;

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_CMF = ffi.cast(pv, CMF.ffi_ptr); 
        ffi_volume = ffi.cast(pv, source.volume.ffi_ptr);	
        ffi_AD_DATA = ffi.cast(pv, AD.DATA.ffi_ptr);
        ffi_AD = ffi.cast(pv, AD.ffi_ptr);
    end

end

if ffi then

function Update(period, mode)

    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_AD);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_AD, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_AD, true);		
    end

    if period >= first then
        local from = period - N + 1;
        local a, b;
        a = indicore3_ffi.core_math_sum(ffi_AD_DATA, from, period);        
        b = indicore3_ffi.core_math_sum(ffi_volume, from, period);
        if b ~= 0 then
            indicore3_ffi.outputstreamimpl_set(ffi_CMF, period, a / b);
        else
            indicore3_ffi.outputstreamimpl_set(ffi_CMF, period, 0);
        end

        if not(line) then
            if indicore3_ffi.stream_getPrice(ffi_CMF, period) > 0 then
                indicore3_ffi.outputstreamimpl_setColor(ffi_CMF, period, U);
            else
                indicore3_ffi.outputstreamimpl_setColor(ffi_CMF,period, D);
            end
        end
    end
end

else

function Update(period, mode)
    AD:update(mode);

    if period >= first then
        local from = period - N + 1;
        local a, b;
        a = mathex.sum(AD.DATA, from, period);
        b = mathex.sum(source.volume, from, period);
        if b ~= 0 then
            CMF[period] = a / b;
        else
            CMF[period] = 0;
        end

        if not(line) then
            if CMF[period] > 0 then
                CMF:setColor(period, U);
            else
                CMF:setColor(period, D);
            end
        end
    end
end

end