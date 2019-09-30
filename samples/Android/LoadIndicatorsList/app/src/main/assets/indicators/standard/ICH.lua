-- The indicator corresponds to the Ichimoku Kinko Hyo indicator in MetaTrader.

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("X", resources:get("param_X_name"), resources:get("param_X_description"), 9, 1, 10000);
    indicator.parameters:addInteger("Y", resources:get("param_Y_name"), resources:get("param_Y_description"), 26, 1, 10000);
    indicator.parameters:addInteger("Z", resources:get("param_Z_name"), resources:get("param_Z_description"), 52, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrTS", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_TS_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_TS_line_desc")), core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthSL", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_TS_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_TS_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleSL", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_TS_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_TS_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleSL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrKS", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_KS_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_KS_line_desc")), core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthTL", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_KS_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_KS_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleTL", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_KS_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_KS_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleTL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrCS", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_CS_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_CS_line_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthCS", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_CS_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_CS_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleCS", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_CS_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_CS_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleCS", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSA", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_SSA_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_SSA_line_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSSA", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_SSA_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_SSA_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleSSA", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_SSA_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_SSA_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSA", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSB", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_SSB_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_SSB_line_desc")), core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSSB", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_SSB_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_SSB_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleSSB", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_SSB_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_SSB_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSB", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addInteger("transp", resources:get("param_transp_name"), resources:get("param_transp_description"), 80, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Tenkan;
local Kijun;
local Senkou;

local firstPeriod;
local source = nil;

local csFirst = nil;
local slFirst = nil;
local tlFirst = nil;
local saFirst = nil;
local sbFirst = nil;
local chFirst = nil;

-- Streams block
local SL = nil;
local TL = nil;
local CS = nil;
local SA = nil;
local SB = nil;
local SA1 = nil;
local SB2 = nil;
local clrSSA, clrSSB;

if ffi then
    local ffi_source;
    local ffi_SL;
    local ffi_TL;
    local ffi_CS;
    local ffi_SA;
    local ffi_SB;
    local ffi_SA1;
    local ffi_SB1;
    local ffi_source_close;
end

-- Routine
function Prepare()
    Tenkan = instance.parameters.X;
    Kijun = instance.parameters.Y;
    Senkou = instance.parameters.Z;
    source = instance.source;
    firstPeriod = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Tenkan .. ", " .. Kijun .. ", " .. Senkou .. ")";
    instance:name(name);
    SL = instance:addStream("SL", core.Line, name .. ".TL", "TL", instance.parameters.clrTS, firstPeriod + Tenkan - 1)
    SL:setWidth(instance.parameters.widthSL);
    SL:setStyle(instance.parameters.styleSL);
    TL = instance:addStream("TL", core.Line, name .. ".KL", "KL", instance.parameters.clrKS, firstPeriod + Kijun - 1)
    TL:setWidth(instance.parameters.widthTL);
    TL:setStyle(instance.parameters.styleTL);
    CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS, firstPeriod, -Kijun)
    CS:setWidth(instance.parameters.widthCS);
    CS:setStyle(instance.parameters.styleCS);
    SA = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrSSA, math.max(SL:first(), TL:first()), Kijun)
    SA:setWidth(instance.parameters.widthSSA);
    SA:setStyle(instance.parameters.styleSSA);
    SB = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrSSB, firstPeriod + Senkou - 1, Kijun)
    SB:setWidth(instance.parameters.widthSSB);
    SB:setStyle(instance.parameters.styleSSB);

    csFirst = CS:first() + Kijun;
    slFirst = SL:first();
    tlFirst = TL:first();
    saFirst = SA:first();
    sbFirst = SB:first();

    chFirst = math.max(saFirst, sbFirst);
    SA1 = instance:addInternalStream(chFirst, Kijun);
    SB1 = instance:addInternalStream(chFirst, Kijun);
    instance:createChannelGroup("SA-SB", "SA-SB", SA1, SB1, instance.parameters.clrSSA, 100 - instance.parameters.transp);
    clrSSA = instance.parameters.clrSSA;
    clrSSB = instance.parameters.clrSSB;
	
    if ffi then    
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_SL = ffi.cast(pv, SL.ffi_ptr);
        ffi_TL = ffi.cast(pv, TL.ffi_ptr);
        ffi_CS = ffi.cast(pv, CS.ffi_ptr);
        ffi_SA = ffi.cast(pv, SA.ffi_ptr);
        ffi_SB = ffi.cast(pv, SB.ffi_ptr);
        ffi_SA1 = ffi.cast(pv, SA1.ffi_ptr);
        ffi_SB1 = ffi.cast(pv, SB1.ffi_ptr);
        ffi_source_close = ffi.cast(pv, source.close.ffi_ptr);       
    end
	
end


-- Indicator calculation routine
if ffi then

function mathex_minmax(stream, from, to)

    local maxVal = -1.7976931348623158e+308
    local minVal = 1.7976931348623158e+308

    local maxPos = -1;
    local minPos = -1;

    if indicore3_ffi.stream_isBar(stream) == true then
        for i = from , to, 1  do
           local high = indicore3_ffi.barstream_getHigh(stream, i);
           local low = indicore3_ffi.barstream_getLow(stream, i);
           if maxVal < high then
               maxVal = high;
               maxPos = i;
           end
           if  minVal > low then
               minVal = low;
               minPos = i;
           end     
        end
    else
        for i = from , to, 1 do
            local t= indicore3_ffi.stream_getPrice(stream, i);
            if maxVal < t then
                maxVal = t;
                maxPos = i;
            end
            if minVal > t then
                minVal = t;
                minPos = i;
            end
        end
    end
    return minVal, maxVal, minPos, maxPos 
end

function Update(period)
    if (period >= csFirst) then
        indicore3_ffi.outputstreamimpl_set(ffi_CS,
                                           period - Kijun,
                                           indicore3_ffi.stream_getPrice(ffi_source_close, period));
    end
	
    local p, hh, ll;

    if (period >= slFirst) then
        ll, hh = mathex_minmax(ffi_source, period - Tenkan + 1, period);
        indicore3_ffi.outputstreamimpl_set(ffi_SL, period, (hh + ll) / 2);
    end
	
    if (period >= tlFirst) then
       ll, hh = mathex_minmax(ffi_source, period - Kijun + 1, period);
       indicore3_ffi.outputstreamimpl_set(ffi_TL, period, (hh + ll) / 2);
    end

    local p = period + Kijun;

    if (period >= saFirst) then
        indicore3_ffi.outputstreamimpl_set(ffi_SA,
                                           p,
                                           (indicore3_ffi.stream_getPrice(ffi_SL, period) + 
                                           indicore3_ffi.stream_getPrice(ffi_TL, period)) / 2);
    end

    if (period >= sbFirst) then
           ll, hh = mathex_minmax(ffi_source, period - Senkou + 1, period);
           indicore3_ffi.outputstreamimpl_set(ffi_SB, p, (hh + ll) / 2);
    end

    if (period >= chFirst) then
        indicore3_ffi.outputstreamimpl_set(ffi_SA1, p, indicore3_ffi.stream_getPrice(ffi_SA, p));
        indicore3_ffi.outputstreamimpl_set(ffi_SB1, p, indicore3_ffi.stream_getPrice(ffi_SB, p));
        if (indicore3_ffi.stream_getPrice(ffi_SA, p) > indicore3_ffi.stream_getPrice(ffi_SB, p)) then
            indicore3_ffi.outputstreamimpl_setColor(ffi_SA1, p, clrSSB);
        else
            indicore3_ffi.outputstreamimpl_setColor(ffi_SA1, p, clrSSA);
        end
    end
end

else

function Update(period)
    if (period >= csFirst) then
        CS[period - Kijun] = source.close[period];
    end

    local p, hh, ll;

    if (period >= slFirst) then
        ll, hh = mathex.minmax(source, period - Tenkan + 1, period);
        SL[period] = (hh + ll) / 2;
    end

    if (period >= tlFirst) then
        ll, hh = mathex.minmax(source, period - Kijun + 1, period);
        TL[period] = (hh + ll) / 2;
    end

    local p = period + Kijun;

    if (period >= saFirst) then
        SA[p] = (SL[period] + TL[period]) / 2;
    end

    if (period >= sbFirst) then
        ll, hh = mathex.minmax(source, period - Senkou + 1, period);
        SB[p] = (hh + ll) / 2;
    end

    if (period >= chFirst) then
        SA1[p] = SA[p];
        SB1[p] = SB[p];
        if (SA[p] > SB[p]) then
            SA1:setColor(p, clrSSB);
        else
            SA1:setColor(p, clrSSA);
        end
    end
	

end

end