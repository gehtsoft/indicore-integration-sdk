-- The indicator is based on EWO.
-- The formula of EWO is described in the Kaufman "Trading Systems and Methods" chapter 14 "Behavioral techniques" (page 358-361)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Waves");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Trigger", resources:get("param_Trigger_name"), resources:get("param_Trigger_description"), 70, 2, 1000);
    indicator.parameters:addInteger("Period", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 20, 2, 1000);
    indicator.parameters:addInteger("FastN", resources:get("param_FN_name"), resources:get("param_FN_description"), 5, 2, 1000);
    indicator.parameters:addInteger("SlowN", resources:get("param_SN_name"), resources:get("param_SN_description"), 35, 2, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrEWN", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_EWN_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthEWN", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_EWN_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleEWN", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_EWN_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleEWN", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Trigger;
local Period;

local first;
local source = nil;
local hMean = nil;
local trend = nil;
local hiOsc = nil;
local hiOsc2 = nil;
local hiPrice = nil;
local hiPrice2 = nil;
local ewo = nil;
local ew = nil;

-- Streams block
local EWN = nil;
local ewoStream = nil;

if ffi then 
    local ffi_source;
    local ffi_ewo;
    local ffi_ew;
    local ffi_hMean;
    local ffi_hiOsc;
    local ffi_hiOsc2;
    local ffi_hiPrice;
    local ffi_hiPrice2;
    local ffi_EWN; 
    local ffi_median;
    local ffi_ew_DATA;
    local ffi_ewo_DATA;
end

-- Routine
function Prepare()
    source = instance.source;
    ewo = core.indicators:create("EWO", source, instance.parameters.FastN, instance.parameters.SlowN, "M2", "MVA", "No");
    ew = core.indicators:create("EW", source, instance.parameters.Trigger, instance.parameters.Period, instance.parameters.FastN, instance.parameters.SlowN);

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Trigger .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.FastN .. ", " .. instance.parameters.SlowN .. ")";
    instance:name(name);

    hMean = instance:addInternalStream(0, 0);
    hiOsc = instance:addInternalStream(0, 0);
    hiOsc2 = instance:addInternalStream(0, 0);
    hiPrice = instance:addInternalStream(0, 0);
    hiPrice2 = instance:addInternalStream(0, 0);

    first = ew.DATA:first() + 1;
    EWN = instance:addStream("EWN", core.Line, name, "EWN", instance.parameters.clrEWN, first)
    EWN:setWidth(instance.parameters.widthEWN);
    EWN:setStyle(instance.parameters.styleEWN);
    EWN:setPrecision(4);
    EWN:addLevel(0);
    EWN:addLevel(5);

    if ffi then
        
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_ewo = ffi.cast(pv, ewo.ffi_ptr);
        ffi_ew = ffi.cast(pv, ew.ffi_ptr);
        ffi_hMean = ffi.cast(pv, hMean.ffi_ptr);
        ffi_hiOsc = ffi.cast(pv, hiOsc.ffi_ptr);
        ffi_hiOsc2 = ffi.cast(pv, hiOsc2.ffi_ptr);
        ffi_hiPrice = ffi.cast(pv, hiPrice.ffi_ptr);
        ffi_hiPrice2 = ffi.cast(pv, hiPrice2.ffi_ptr);
        ffi_EWN = ffi.cast(pv, EWN.ffi_ptr);
        ffi_median = ffi.cast(pv, source.median.ffi_ptr);
        ffi_ew_DATA = ffi.cast(pv, ew.DATA.ffi_ptr);
        ffi_ewo_DATA = ffi.cast(pv, ewo.DATA.ffi_ptr);
       
    end
	
	
end

-- Indicator calculation routine
if ffi then

function mathex_max(stream, from, to)

    local maxVal = -1.7976931348623158e+308
    local maxPos = -1;

    for i = from , to, 1 do
        local t = indicore3_ffi.stream_getPrice(stream, i);
        if maxVal < t then        
            maxVal = t;
            maxPos = i;
        end
    end

    return maxVal, maxPos; 
end

function Update(period, mode)

    if  mode == core.UpdateAll then
            indicore3_ffi.indicatorinstance_updateAll(ffi_ewo);
    elseif mode == core.UpdateNew then
            indicore3_ffi.indicatorinstance_update(ffi_ewo, false);
        else
            indicore3_ffi.indicatorinstance_update(ffi_ewo, true);		
    end

    if  mode == core.UpdateAll then
            indicore3_ffi.indicatorinstance_updateAll(ffi_ew);
    elseif mode == core.UpdateNew then
            indicore3_ffi.indicatorinstance_update(ffi_ew, false);
        else
            indicore3_ffi.indicatorinstance_update(ffi_ew, true);		
    end

    local mean;
    if period >= source:first() then
        mean = indicore3_ffi.stream_getPrice(ffi_median, period);
        indicore3_ffi.outputstreamimpl_set(ffi_hMean, period, mean);
    else
        return ;
    end
	
    if period == 0 then
        indicore3_ffi.outputstreamimpl_set(ffi_hiOsc, period, -999);
        indicore3_ffi.outputstreamimpl_set(ffi_hiOsc2, period, -999);
        indicore3_ffi.outputstreamimpl_set(ffi_hiPrice, period, -999);
        indicore3_ffi.outputstreamimpl_set(ffi_hiPrice2, period, -999);
        indicore3_ffi.outputstreamimpl_set(ffi_EWN, period, 0);
    else
        indicore3_ffi.outputstreamimpl_set(ffi_hiOsc, period, indicore3_ffi.stream_getPrice(ffi_hiOsc, period - 1));
        indicore3_ffi.outputstreamimpl_set(ffi_hiOsc2, period, indicore3_ffi.stream_getPrice(ffi_hiOsc2, period - 1));
        indicore3_ffi.outputstreamimpl_set(ffi_hiPrice, period, indicore3_ffi.stream_getPrice(ffi_hiPrice, period - 1));
        indicore3_ffi.outputstreamimpl_set(ffi_hiPrice2, period, indicore3_ffi.stream_getPrice(ffi_hiPrice2, period - 1));
        indicore3_ffi.outputstreamimpl_set(ffi_EWN, period, indicore3_ffi.stream_getPrice(ffi_EWN, period - 1));
    end

    if period >= first then
        local wave = indicore3_ffi.stream_getPrice(ffi_EWN, period);
        local osc = indicore3_ffi.stream_getPrice(ffi_ewo_DATA, period);
        local et = indicore3_ffi.stream_getPrice(ffi_ew_DATA, period);

        indicore3_ffi.outputstreamimpl_set(ffi_hMean, period, mean);

        if et == 1 and indicore3_ffi.stream_getPrice(ffi_ew_DATA, period - 1) == -1 and osc > 0 then
            indicore3_ffi.outputstreamimpl_set(ffi_hiOsc, period, osc);
            indicore3_ffi.outputstreamimpl_set(ffi_hiPrice, period, mean);
            wave = 3;
        end

        if wave == 3 then
            if mean > indicore3_ffi.stream_getPrice(ffi_hiPrice, period) then
                indicore3_ffi.outputstreamimpl_set(ffi_hiPrice, period, mean);
            end
            if osc > indicore3_ffi.stream_getPrice(ffi_hiOsc, period) then
                indicore3_ffi.outputstreamimpl_set(ffi_hiOsc, period, osc);
            end
            if osc <= 0 and et == 1 then
                wave = 4;
            end
        end

        local himean = mathex_max(ffi_hMean, period - 4, period);

         if wave == 4 and mean == himean and osc >= 0 then
            wave = 5;
            indicore3_ffi.outputstreamimpl_set(ffi_hiOsc2, period, osc);
            indicore3_ffi.outputstreamimpl_set(ffi_hiPrice2, period, mean);
        end

        if wave == 5 then
            if osc > indicore3_ffi.stream_getPrice(ffi_hiOsc2, period) then
                indicore3_ffi.outputstreamimpl_set(ffi_hiOsc2, period, osc);
            end
            if mean > indicore3_ffi.stream_getPrice(ffi_hiPrice2, period) then
                indicore3_ffi.outputstreamimpl_set(ffi_hiPrice2, period, mean);
            end
        end

        if wave == 5 and indicore3_ffi.stream_getPrice(ffi_hiOsc2, period) > indicore3_ffi.stream_getPrice(ffi_hiOsc, period) and et == 1 then
            wave = 3;
            indicore3_ffi.outputstreamimpl_set(ffi_hiOsc, period, indicore3_ffi.stream_getPrice(ffi_hiOsc2, period));
            indicore3_ffi.outputstreamimpl_set(ffi_hiPrice, period, indicore3_ffi.stream_getPrice(ffi_hiPrice2, period));
            indicore3_ffi.outputstreamimpl_set(ffi_hiOsc2, period, -999);
            indicore3_ffi.outputstreamimpl_set(ffi_hiPrice2, period, -999);
        end

        if wave == 5 and et == -1 then
            wave = 3;
            indicore3_ffi.outputstreamimpl_set(ffi_hiOsc, period, -999);
            indicore3_ffi.outputstreamimpl_set(ffi_hiPrice, period, -999);
            indicore3_ffi.outputstreamimpl_set(ffi_hiOsc2, period, -999);
            indicore3_ffi.outputstreamimpl_set(ffi_hiPrice2, period, -999);
        end

        indicore3_ffi.outputstreamimpl_set(ffi_EWN, period, wave);
    end
end

else

function Update(period, mode)
    ewo:update(mode);
    ew:update(mode);

    local mean;
    if period >= source:first() then
        mean = source.median[period];
        hMean[period] = mean;
    else
        return ;
    end

    if period == 0 then
        hiOsc[period] = -999;
        hiOsc2[period] = -999;
        hiPrice[period] = -999;
        hiPrice2[period] = -999;
        EWN[period] = 0;
    else
        hiOsc[period] = hiOsc[period - 1];
        hiOsc2[period] = hiOsc2[period - 1];
        hiPrice[period] = hiPrice[period - 1];
        hiPrice2[period] = hiPrice2[period - 1];
        EWN[period] = EWN[period - 1];
    end


    if period >= first then
        local wave = EWN[period];
        local osc = ewo.DATA[period];
        local et = ew.DATA[period];

        hMean[period] = mean;

        if et == 1 and ew.DATA[period - 1] == -1 and osc > 0 then
            hiOsc[period] = osc;
            hiPrice[period] = mean;
            wave = 3;
        end

        if wave == 3 then
            if mean > hiPrice[period] then
                hiPrice[period] = mean;
            end
            if osc > hiOsc[period] then
                hiOsc[period] = osc;
            end
            if osc <= 0 and et == 1 then
                wave = 4;
            end
        end

        local himean = mathex.max(hMean, period - 4, period);

        if wave == 4 and mean == himean and osc >= 0 then
            wave = 5;
            hiOsc2[period] = osc;
            hiPrice2[period] = mean;
        end

        if wave == 5 then
            if osc > hiOsc2[period] then
                hiOsc2[period] = osc;
            end
            if mean > hiPrice2[period] then
                hiPrice2[period] = mean;
            end
        end

        if wave == 5 and hiOsc2[period] > hiOsc[period] and et == 1 then
            wave = 3;
            hiOsc[period] = hiOsc2[period];
            hiPrice[period] = hiPrice2[period];
            hiOsc2[period] = -999;
            hiPrice2[period] = -999;
        end

        if wave == 5 and et == -1 then
            wave = 3;
            hiOsc[period] = -999;
            hiPrice[period] = -999;
            hiOsc2[period] = -999;
            hiPrice2[period] = -999;
        end


        EWN[period] = wave;
    end
end

end