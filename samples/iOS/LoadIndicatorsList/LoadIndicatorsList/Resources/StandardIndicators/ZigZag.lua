-- Indicator profile initialization routine
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Swing");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", resources:get("param_Depth_name"), resources:get("param_Depth_description"), 12, 1, 10000);
    indicator.parameters:addInteger("Deviation", resources:get("param_Deviation_name"), resources:get("param_Deviation_description"), 5, 1, 1000);
    indicator.parameters:addInteger("Backstep", resources:get("param_Backstep_name"), resources:get("param_Backstep_description"), 3, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Zig_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_Zig_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_Zig_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addColor("Zag_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_Zag_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_Zag_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthZigZag", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_ZigZag_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleZigZag", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_ZigZag_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleZigZag", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth;
local Deviation;
local Backstep;

local first;
local source = nil;

-- Streams block
local ZigC;
local ZagC;
local out;
local HighMap = nil;
local LowMap = nil;

if ffi then 
    local ffi_source;
    local ffi_out;
    local ffi_HighMap;
    local ffi_LowMap;
    local ffi_SearchMode;
    local ffi_Peak;
    local ffi_source_low;
    local ffi_source_high;
end

-- Routine
function Prepare()
    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep .. ")";
    instance:name(name);
    out = instance:addStream("out", core.Line, name, "Up", instance.parameters.Zig_color, first);
    out:setWidth(instance.parameters.widthZigZag);
    out:setStyle(instance.parameters.styleZigZag);
    ZigC = instance.parameters.Zig_color;
    ZagC = instance.parameters.Zag_color;

    HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
    SearchMode = instance:addInternalStream(0, 0);
    Peak = instance:addInternalStream(0, 0);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_out = ffi.cast(pv, out.ffi_ptr);
        ffi_HighMap = ffi.cast(pv, HighMap.ffi_ptr);
        ffi_LowMap = ffi.cast(pv, LowMap.ffi_ptr);
        ffi_SearchMode = ffi.cast(pv, SearchMode.ffi_ptr);
        ffi_Peak = ffi.cast(pv, Peak.ffi_ptr);
        ffi_source_low = ffi.cast(pv, source.low.ffi_ptr);
        ffi_source_high = ffi.cast(pv, source.high.ffi_ptr);
    end
end

local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;
local lastlow = nil;
local lashhigh = nil;

-- optimization hint
local peak_count = 0;


local lastperiod = -1;

if ffi then 

function GetPeak(offset)
    local peak;
    peak = peak_count + offset;
    if peak < 1 then
        return -1;
    end
    peak = indicore3_ffi.outputstreamimpl_getBookmark(ffi_out, peak);
    if peak < 0 then
        return -1;
    end
    return peak;
end

function ReplaceLastPeak(period, mode, peak)

    indicore3_ffi.outputstreamimpl_setBookmark(ffi_out, peak_count, period);
    indicore3_ffi.outputstreamimpl_set(ffi_SearchMode, period, mode);
    indicore3_ffi.outputstreamimpl_set(ffi_Peak, period, peak);
end

function RegisterPeak(period, mode, peak)

    peak_count = peak_count + 1;
    indicore3_ffi.outputstreamimpl_setBookmark(ffi_out, peak_count, period);
    indicore3_ffi.outputstreamimpl_set(ffi_SearchMode, period, mode);
    indicore3_ffi.outputstreamimpl_set(ffi_Peak, period, peak);
end

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

function mathex_min(stream, from, to) 

    local minVal = 1.7976931348623158e+308
    local minPos = 1;

    for i = from , to, 1 do
        local t = indicore3_ffi.stream_getPrice(stream, i);
        if minVal > t then        
            minVal = t;
            minPos = i;
        end
    end

    return minVal, minPos; 
  
end

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1;

    if period == lastperiod then
        return ;
    end

    if period < lastperiod then
        lastlow = nil;
        lasthigh = nil;
        peak_count = 0;
    end

    lastperiod = period;

    if period >= Depth then
    -- fill high/low maps
    local range = period - Depth + 1;
    local val;
    local i;
    -- get the lowest low for the last depth periods
    val = mathex_min(ffi_source_low, range, period);
    if val == lastlow then
        -- if lowest low is not changed - ignore it
        val = nil;
    else
        -- keep it
        lastlow = val;
        -- if current low is higher for more than Deviation pips, ignore
        if (indicore3_ffi.stream_getPrice(ffi_source_low, period) - val) > (indicore3_ffi.stream_pipSize(ffi_source) * Deviation) then
            val = nil;
        else
            -- check for the previous backstep lows
            local price;
            for i = period - 1, period - Backstep + 1, -1 do
                  price = indicore3_ffi.stream_getPrice(ffi_LowMap, i); --
                  if (price ~= 0) and (price > val) then
                      indicore3_ffi.outputstreamimpl_set(ffi_LowMap, i, 0);
                end
            end         
        end
    end

    if indicore3_ffi.stream_getPrice(ffi_source_low, period) == val then
        indicore3_ffi.outputstreamimpl_set(ffi_LowMap, period, val);
    else
        indicore3_ffi.outputstreamimpl_set(ffi_LowMap, period, 0);
    end
  
    val = mathex_max(ffi_source_high, range, period);
    if val == lasthigh then
        -- if lowest low is not changed - ignore it
        val = nil;
    else
        -- keep it
        lasthigh = val;
        -- if current low is higher for more than Deviation pips, ignore
        if (val - indicore3_ffi.stream_getPrice(ffi_source_high, period)) > (indicore3_ffi.stream_pipSize(ffi_source) * Deviation) then
           val = nil;
        else
            -- check for the previous backstep lows
            local price;
            for i = period - 1, period - Backstep + 1, -1 do
                price = indicore3_ffi.stream_getPrice(ffi_HighMap, i);
                if (price ~= 0) and (price < val) then
                   indicore3_ffi.outputstreamimpl_set(ffi_HighMap, i, 0);
                end
            end
        end
    end
		
    if indicore3_ffi.stream_getPrice(ffi_source_high, period) == val then
        indicore3_ffi.outputstreamimpl_set(ffi_HighMap, period, val);
    else
        indicore3_ffi.outputstreamimpl_set(ffi_HighMap, period, 0);
    end

    local start;
    local last_peak;
    local last_peak_i;
    local prev_peak;
    local searchMode = searchBoth;

    i = GetPeak(-4);
    if i == -1 then
        prev_peak = nil;
    else
        prev_peak = i;
    end

    start = Depth;
    i = GetPeak(-3);
    if i == -1 then
        last_peak_i = nil;
        last_peak = nil;
    else
        last_peak_i = i;
        last_peak = Peak[i];
        searchMode = SearchMode[i];
        start = i;
    end
		
    peak_count = peak_count - 3;

    for i = start, period, 1 do
        if searchMode == searchBoth then
            if (indicore3_ffi.stream_getPrice(ffi_HighMap, i) ~= 0) then
                last_peak_i = i;
                last_peak = indicore3_ffi.stream_getPrice(ffi_HighMap, i);
                searchMode = searchLawn;
                RegisterPeak(i, searchMode, last_peak);
            elseif (indicore3_ffi.stream_getPrice(ffi_LowMap, i) ~= 0) then
                last_peak_i = i;
                last_peak = indicore3_ffi.stream_getPrice(ffi_LowMap, i);
                searchMode = searchPeak;
                RegisterPeak(i, searchMode, last_peak);
            end     

        elseif searchMode == searchPeak then
               local price = indicore3_ffi.stream_getPrice(ffi_LowMap, i); 
               if price ~= 0 and price < last_peak then

                   last_peak = price;
                   last_peak_i = i;
                    if prev_peak ~= nil then
                        if indicore3_ffi.stream_getPrice(ffi_Peak, prev_peak) > price then

                            indicore3_ffi.core_drawLine(ffi_out, 
                                                        prev_peak,
                                                        i, 
                                                        indicore3_ffi.stream_getPrice(ffi_Peak, prev_peak),
                                                        prev_peak,
                                                        price,
                                                        i,
                                                        ZagC);

                            indicore3_ffi.outputstreamimpl_setColor(ffi_out, prev_peak, ZigC);
                        else
                            from , to = core.range(prev_peak, i);
                            indicore3_ffi.core_drawLine(ffi_out,
                                                        prev_peak,
                                                        i,
                                                        indicore3_ffi.stream_getPrice(ffi_Peak, prev_peak),
                                                        prev_peak,
                                                        price,
                                                        i,
                                                        ZigC);
                            indicore3_ffi.outputstreamimpl_setColor(ffi_out, prev_peak, ZagC);
                        end
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end

                local pHighMap = indicore3_ffi.stream_getPrice(ffi_HighMap, i); 
                if pHighMap ~= 0 and price == 0 then
                    indicore3_ffi.core_drawLine(ffi_out,
                                                last_peak_i,
                                                i,
                                                last_peak,
                                                last_peak_i,
                                                pHighMap,
                                                i,
                                                ZigC);
                    indicore3_ffi.outputstreamimpl_setColor(ffi_out, last_peak_i, ZagC);
                    prev_peak = last_peak_i;
                    last_peak = pHighMap;
                    last_peak_i = i;
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                end

        elseif searchMode == searchLawn then
                local pHighMap = indicore3_ffi.stream_getPrice(ffi_HighMap, i); 
                if (pHighMap ~= 0 and pHighMap > last_peak) then
                    last_peak = pHighMap;
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        from_to = prev_peak - i;
                        indicore3_ffi.core_drawLine(ffi_out,
                                                prev_peak,
                                                i, 
                                                indicore3_ffi.stream_getPrice(ffi_Peak, prev_peak),
                                                prev_peak, 
                                                pHighMap,
                                                i,
                                                ZigC);
                        indicore3_ffi.outputstreamimpl_setColor(ffi_out, prev_peak, ZagC);
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end

                local pLowMap = indicore3_ffi.stream_getPrice(ffi_LowMap, i);

                if pLowMap ~= 0 and pHighMap == 0 then
                    if  last_peak > pLowMap then

                        indicore3_ffi.core_drawLine(ffi_out,
                                                    last_peak_i, 
                                                    i,
                                                    last_peak,
                                                    last_peak_i,
                                                    pLowMap, 
                                                    i,
                                                    ZagC);

                        indicore3_ffi.outputstreamimpl_setColor(ffi_out, last_peak_i, ZigC);
                    else
                        indicore3_ffi.core_drawLine(ffi_out,
                                                    last_peak_i, 
                                                    i,
                                                    last_peak,
                                                    last_peak_i,
                                                    pLowMap, 
                                                    i,
                                                    ZigC);

                        indicore3_ffi.outputstreamimpl_setColor(ffi_out, last_peak_i, ZagC);

                    end
                    prev_peak = last_peak_i;
                    last_peak = pLowMap;
                    last_peak_i = i;
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end 

            end
        end
    end
end

else 

function GetPeak(offset)
    local peak;
    peak = peak_count + offset;
    if peak < 1 then
        return -1;
    end
    peak = out:getBookmark(peak);
    if peak < 0 then
        return -1;
    end
    return peak;
end

function ReplaceLastPeak(period, mode, peak)
    --peak_count = peak_count + 1;
    out:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function RegisterPeak(period, mode, peak)
    peak_count = peak_count + 1;
    out:setBookmark(peak_count, period);
    SearchMode[period] = mode;
    Peak[period] = peak;
end

function Update(period, mode)
    -- calculate zigzag for the completed candle ONLY
    period = period - 1;

    if period == lastperiod then
        return ;
    end

    if period < lastperiod then
        lastlow = nil;
        lasthigh = nil;
        peak_count = 0;
    end

    lastperiod = period;

    if period >= Depth then
        -- fill high/low maps
        local range = period - Depth + 1;
        local val;
        local i;
        -- get the lowest low for the last depth periods
        val = mathex.min(source.low, range, period);
        if val == lastlow then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lastlow = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (source.low[period] - val) > (source:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (LowMap[i] ~= 0) and (LowMap[i] > val) then
                        LowMap[i] = 0;
                    end
                end
            end
        end
				
        if source.low[period] == val then
            LowMap[period] = val;
        else
            LowMap[period] = 0;
        end
        -- get the lowest low for the last depth periods
        val = mathex.max(source.high, range, period);
        if val == lasthigh then
            -- if lowest low is not changed - ignore it
            val = nil;
        else
            -- keep it
            lasthigh = val;
            -- if current low is higher for more than Deviation pips, ignore
            if (val - source.high[period]) > (source:pipSize() * Deviation) then
               val = nil;
            else
                -- check for the previous backstep lows
                for i = period - 1, period - Backstep + 1, -1 do
                    if (HighMap[i] ~= 0) and (HighMap[i] < val) then
                        HighMap[i] = 0;
                    end
                end
            end
        end
		
        if source.high[period] == val then
            HighMap[period] = val;
        else
            HighMap[period] = 0
        end

        local start;
        local last_peak;
        local last_peak_i;
        local prev_peak;
        local searchMode = searchBoth;

        i = GetPeak(-4);
        if i == -1 then
            prev_peak = nil;
        else
            prev_peak = i;
        end

        start = Depth;
        i = GetPeak(-3);
        if i == -1 then
            last_peak_i = nil;
            last_peak = nil;
        else
            last_peak_i = i;
            last_peak = Peak[i];
            searchMode = SearchMode[i];
            start = i;
        end
		
        peak_count = peak_count - 3;

        for i = start, period, 1 do
            if searchMode == searchBoth then
                if (HighMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = HighMap[i];
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                elseif (LowMap[i] ~= 0) then
                    last_peak_i = i;
                    last_peak = LowMap[i];
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchPeak then
                if (LowMap[i] ~= 0 and LowMap[i] < last_peak) then
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        if Peak[prev_peak] > LowMap[i] then
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZagC);
                            out:setColor(prev_peak, ZigC);
                        else
                            core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, LowMap[i], i, ZigC);
                            out:setColor(prev_peak, ZagC);
                        end
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if HighMap[i] ~= 0 and LowMap[i] == 0 then
                    core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, HighMap[i], i, ZigC);
                    out:setColor(last_peak_i, ZagC);
                    prev_peak = last_peak_i;
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    searchMode = searchLawn;
                    RegisterPeak(i, searchMode, last_peak);
                end
            elseif searchMode == searchLawn then
                if (HighMap[i] ~= 0 and HighMap[i] > last_peak) then
                    last_peak = HighMap[i];
                    last_peak_i = i;
                    if prev_peak ~= nil then
                        core.drawLine(out, core.range(prev_peak, i), Peak[prev_peak], prev_peak, HighMap[i], i, ZigC);
                        out:setColor(prev_peak, ZagC);
                    end
                    ReplaceLastPeak(i, searchMode, last_peak);
                end
                if LowMap[i] ~= 0 and HighMap[i] == 0 then
                    if  last_peak > LowMap[i] then
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZagC);
                        out:setColor(last_peak_i, ZigC);
                    else
                        core.drawLine(out, core.range(last_peak_i, i), last_peak, last_peak_i, LowMap[i], i, ZigC);
                        out:setColor(last_peak_i, ZagC);
                    end
                    prev_peak = last_peak_i;
                    last_peak = LowMap[i];
                    last_peak_i = i;
                    searchMode = searchPeak;
                    RegisterPeak(i, searchMode, last_peak);
                end
            end
        end
    end
end

end