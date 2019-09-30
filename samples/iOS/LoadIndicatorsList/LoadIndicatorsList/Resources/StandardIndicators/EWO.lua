-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 14 "Behavioral techniques" (page 358-361)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Waves");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastN", resources:get("param_FN_name"), resources:get("param_FN_description"), 5, 2, 1000);
    indicator.parameters:addInteger("SlowN", resources:get("param_SN_name"), resources:get("param_SN_description"), 35, 2, 1000);

    indicator.parameters:addString("Source", resources:get("param_Source_name"), resources:get("param_Source_description"), "M2");
    indicator.parameters:addStringAlternative("Source", resources:get("param_Source_valueM3"), "", "M3");
    indicator.parameters:addStringAlternative("Source", resources:get("param_Source_valueM2"), "", "M2");
    indicator.parameters:addStringAlternative("Source", resources:get("param_Source_valueC"), "", "C");

    indicator.parameters:addString("Method", resources:get("param_Smooth_name"), resources:get("param_Smooth_description"), "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1995)", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("Method", "Wilders", "", "WMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUpGrow", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_UPG_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_UPG_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrUpFall", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_UPF_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_UPF_desc")), core.rgb(0, 127, 0));
    indicator.parameters:addColor("clrDnGrow", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_DNG_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_DNG_desc")), core.rgb(127, 0, 0));
    indicator.parameters:addColor("clrDnFall", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_DNF_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_DNF_desc")), core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
local first;
local first1;
local source = nil;

-- Streams block
local FMA = nil;
local SMA = nil;
local EWO = nil;
local UPGROW = nil;
local UPFALL = nil;
local DNGROW = nil;
local DNFALL = nil;
local DUMMY = nil;
local srcmode;
local prior;

if ffi then 
    local ffi_source;
    local ffi_EWO;
    local ffi_FMA;
    local ffi_SMA;
    local ffi_FMA_DATA;
    local ffi_SMA_DATA;
end

-- Routine
function Prepare()
    assert(instance.parameters.FastN < instance.parameters.SlowN, "Fast MA must be faster than Slow MA");
    srcmode = instance.parameters.Source;
    source = instance.source;
    first1 = source:first();

    local SRC;
    
    if srcmode == "M3" then
        SRC = source.typical;
    elseif srcmode == "M2" then
        SRC = source.median;
    else
        SRC = source.close;
    end
    
    FMA = core.indicators:create(instance.parameters.Method, SRC, instance.parameters.FastN);
    SMA = core.indicators:create(instance.parameters.Method, SRC, instance.parameters.SlowN);

    first = math.max(SMA.DATA:first(), FMA.DATA:first());
    first1 = first + 1;
    local name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.FastN .. "," ..  instance.parameters.SlowN .. "," ..  instance.parameters.Method  .. ")";
    instance:name(name);

    local precision = math.max(2, source:getPrecision());
    EWO = instance:addStream("EWO", core.Bar, name .. ".EWO", "EWO", instance.parameters.clrUpGrow, first);
    EWO:setPrecision(precision);

    UPGROW = instance.parameters.clrUpGrow;
    UPFALL = instance.parameters.clrUpFall;
    DNGROW = instance.parameters.clrDnGrow;
    DNFALL = instance.parameters.clrDnFall;
    EWO:addLevel(0);

    if ffi then        
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_EWO = ffi.cast(pv, EWO.ffi_ptr);
        ffi_FMA = ffi.cast(pv, FMA.ffi_ptr);
        ffi_SMA = ffi.cast(pv, SMA.ffi_ptr);
        ffi_FMA_DATA = ffi.cast(pv, FMA.DATA.ffi_ptr);
        ffi_SMA_DATA = ffi.cast(pv, SMA.DATA.ffi_ptr);
     
    end

end

-- Indicator calculation routine
if ffi then
function Update(period, mode)
    local curr, prev;
    
    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_SMA);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_SMA, false);
        else
            indicore3_ffi.indicatorinstance_update(ffi_SMA, true);		
    end

    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_FMA);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_FMA, false);
        else
            indicore3_ffi.indicatorinstance_update(ffi_FMA, true);		
    end

    if period >= first then
        indicore3_ffi.outputstreamimpl_set(ffi_EWO, 
                                           period,
                                           indicore3_ffi.stream_getPrice(ffi_FMA_DATA, period) - 
                                           indicore3_ffi.stream_getPrice(ffi_SMA_DATA, period));
    end

    if period >= first1 then
        curr = indicore3_ffi.stream_getPrice(ffi_EWO, period);
        prior = indicore3_ffi.stream_getPrice(ffi_EWO, period - 1);
        if curr >= 0 then
            if curr > prior then
                indicore3_ffi.outputstreamimpl_setColor(ffi_EWO, period, UPGROW);
            elseif curr < prior then
                indicore3_ffi.outputstreamimpl_setColor(ffi_EWO, period, UPFALL);
            else
                indicore3_ffi.outputstreamimpl_setColor(ffi_EWO, period, indicore3_ffi.outputstream_getColor(ffi_EWO, period - 1));
            end
        elseif curr < 0 then
            if curr > prior then
                indicore3_ffi.outputstreamimpl_setColor(ffi_EWO, period, DNGROW);
            elseif curr < prior then
                indicore3_ffi.outputstreamimpl_setColor(ffi_EWO, period, DNFALL);
            else
                indicore3_ffi.outputstreamimpl_setColor(ffi_EWO,
                                                        period,
                                                        indicore3_ffi.outputstream_getColor(ffi_EWO, period - 1));
            end
        end
    end

end

else

function Update(period, mode)
    local curr, prev;
    SMA:update(mode);
    FMA:update(mode);

    if period >= first then
        EWO[period] = FMA.DATA[period] - SMA.DATA[period];
    end

    if period >= first1 then
        curr = EWO[period];
        prior = EWO[period - 1];
        if curr >= 0 then
            if curr > prior then
                EWO:setColor(period, UPGROW);
            elseif curr < prior then
                EWO:setColor(period, UPFALL);
            else
                EWO:setColor(period, EWO:colorI(period - 1));
            end
        elseif curr < 0 then
            if curr > prior then
                EWO:setColor(period, DNGROW);
            elseif curr < prior then
                EWO:setColor(period, DNFALL);
            else
                EWO:setColor(period, EWO:colorI(period - 1));
            end
        end
    end
end

end