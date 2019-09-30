-- The indicator corresponds to the Parabolic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend Systems" (page 98-99)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("Step", resources:get("param_Step_name"), resources:get("param_Step_description"), 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max", resources:get("param_Max_name"), resources:get("param_Max_description"), 0.2, 0.001, 10);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUp", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_UP_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_UP_line_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthUP", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_UP_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_UP_line_desc")), 1, 1, 5);
    
    indicator.parameters:addColor("clrDown", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_DOWN_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_DOWN_line_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthDOWN", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_DOWN_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_DOWN_line_desc")), 1, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;
local tradeHigh = nil;
local tradeLow = nil;
local parOp = nil;
local position = nil;
local af = nil;
local Step;
local Max;
-- Streams block
local SAR = nil;
local UP = nil;
local DOWN = nil;

if ffi then
    local ffi_source;
    local ffi_tradeHigh;
    local ffi_tradeLow;
    local ffi_parOp;
    local ffi_position;
    local ffi_af;
    local ffi_SAR;
    local ffi_UP;
    local ffi_DOWN;
    local ffi_high;
    local ffi_low;
end

-- Routine
function Prepare()
   source = instance.source;
    first = source:first() + 1;

    Step = instance.parameters.Step;
    Max = instance.parameters.Max;

    local name = profile:id() .. "(" .. source:name() .. "," .. Step .. "," .. Max .. ")";
    instance:name(name);

    
    tradeHigh = instance:addInternalStream(0, 0);
    tradeLow = instance:addInternalStream(0, 0);
    parOp = instance:addInternalStream(0, 0);
    position = instance:addInternalStream(0, 0);
    af = instance:addInternalStream(0, 0);
    SAR = instance:addInternalStream(first, 0);
    UP = instance:addStream("UP", core.Dot, name .. ".Up", "UP", instance.parameters.clrUp, first)
    UP:setWidth(instance.parameters.widthUP);
    DOWN = instance:addStream("DN", core.Dot, name .. ".Dn", "DN", instance.parameters.clrDown, first)
    DOWN:setWidth(instance.parameters.widthDOWN);


    if ffi then
        -- following two lines are critcally important for the performance. comment and see how FFI will
        -- work even slover than a regular Lua code :-)
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_tradeHigh = ffi.cast(pv, tradeHigh.ffi_ptr);
        ffi_tradeLow = ffi.cast(pv, tradeLow.ffi_ptr);
        ffi_parOp = ffi.cast(pv, parOp.ffi_ptr);
        ffi_position = ffi.cast(pv, position.ffi_ptr);
        ffi_af = ffi.cast(pv, af.ffi_ptr);
        ffi_SAR = ffi.cast(pv, SAR.ffi_ptr);
        ffi_UP = ffi.cast(pv, UP.ffi_ptr);
        ffi_DOWN = ffi.cast(pv, DOWN.ffi_ptr);
        ffi_high = ffi.cast(pv, source.high.ffi_ptr);
        ffi_low = ffi.cast(pv, source.low.ffi_ptr);        
    end

end

-- Indicator calculation routine
if ffi then
function Update(period)

    local init = Step;
    local quant = Step;
    local maxVal = Max;
    local lastHighest = 0;
    local lastLowest = 0;
    local high = 0;
    local low = 0;
    local prevHigh = 0;
    local prevLow = 0;

    if period >= first then
        high = indicore3_ffi.stream_getPrice(ffi_high, period);
        low = indicore3_ffi.stream_getPrice(ffi_low, period);
        prevHigh = indicore3_ffi.stream_getPrice(ffi_high, period - 1);
        prevLow = indicore3_ffi.stream_getPrice(ffi_low, period - 1);

        if (period == first) then
            indicore3_ffi.outputstreamimpl_set(ffi_tradeHigh, period, prevHigh);
            indicore3_ffi.outputstreamimpl_set(ffi_tradeLow, period, prevLow);
            indicore3_ffi.outputstreamimpl_set(ffi_position, period, -1);
            indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, prevHigh);
            indicore3_ffi.outputstreamimpl_set(ffi_af, period, 0);
        else
            indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, indicore3_ffi.stream_getPrice(ffi_parOp, period - 1));
            indicore3_ffi.outputstreamimpl_set(ffi_position, period, indicore3_ffi.stream_getPrice(ffi_position, period - 1));
            indicore3_ffi.outputstreamimpl_set(ffi_tradeHigh, period, indicore3_ffi.stream_getPrice(ffi_tradeHigh, period - 1));
            indicore3_ffi.outputstreamimpl_set(ffi_tradeLow, period, indicore3_ffi.stream_getPrice(ffi_tradeLow, period - 1));
            indicore3_ffi.outputstreamimpl_set(ffi_af, period, indicore3_ffi.stream_getPrice(ffi_af, period - 1));
        end
        lastHighest = indicore3_ffi.stream_getPrice(ffi_tradeHigh, period);
        lastLowest = indicore3_ffi.stream_getPrice(ffi_tradeLow, period);
        if high > lastHighest then
            indicore3_ffi.outputstreamimpl_set(ffi_tradeHigh, period, high);
        end
        if low < lastLowest then
            indicore3_ffi.outputstreamimpl_set(ffi_tradeLow, period, low);
        end
        if indicore3_ffi.stream_getPrice(ffi_position, period) == 1 then
            if low < indicore3_ffi.stream_getPrice(ffi_parOp, period) then
                indicore3_ffi.outputstreamimpl_set(ffi_position, period, -1);
                indicore3_ffi.outputstreamimpl_set(ffi_SAR, period, lastHighest);
                if indicore3_ffi.stream_getPrice(ffi_SAR, period) < high then
                    indicore3_ffi.outputstreamimpl_set(ffi_SAR, period, high);
                end
                indicore3_ffi.outputstreamimpl_set(ffi_tradeHigh, period, high);
                indicore3_ffi.outputstreamimpl_set(ffi_tradeLow, period, low);
                indicore3_ffi.outputstreamimpl_set(ffi_af, period, init);
                indicore3_ffi.outputstreamimpl_set(ffi_parOp, 
                                                   period,
                                                   indicore3_ffi.stream_getPrice(ffi_SAR, period) +
                                                   indicore3_ffi.stream_getPrice(ffi_af,period) *
                                                   (indicore3_ffi.stream_getPrice(ffi_tradeLow, period) -
                                                   indicore3_ffi.stream_getPrice(ffi_SAR, period)));
                if (indicore3_ffi.stream_getPrice(ffi_parOp, period) < high) then
                    indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, high);
                end
                if (indicore3_ffi.stream_getPrice(ffi_parOp, period) < prevHigh) then
                    indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, prevHigh);
                end
            else
                indicore3_ffi.outputstreamimpl_set(ffi_SAR,
                                                   period,
                                                   indicore3_ffi.stream_getPrice(ffi_parOp, period));

                if (indicore3_ffi.stream_getPrice(ffi_tradeHigh, period) > indicore3_ffi.stream_getPrice(ffi_tradeHigh, period - 1) and
                    indicore3_ffi.stream_getPrice(ffi_af, period) < maxVal) then
                    indicore3_ffi.outputstreamimpl_set(ffi_af, period, indicore3_ffi.stream_getPrice(ffi_af, period) + quant);
                    if indicore3_ffi.stream_getPrice(ffi_af, period) > maxVal then
                        indicore3_ffi.outputstreamimpl_set(ffi_af, period, maxVal);
                    end
                end

                indicore3_ffi.outputstreamimpl_set(ffi_parOp,
                                                   period,
                                                   indicore3_ffi.stream_getPrice(ffi_SAR, period) + 
                                                   indicore3_ffi.stream_getPrice(ffi_af, period) * 
                                                   (indicore3_ffi.stream_getPrice(ffi_tradeHigh,period) -
                                                    indicore3_ffi.stream_getPrice(ffi_SAR, period)));

                if (indicore3_ffi.stream_getPrice(ffi_parOp, period) > low) then
                    indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, low);
                end
                if (indicore3_ffi.stream_getPrice(ffi_parOp, period) > prevLow) then
                    indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, prevLow);
                end
            end 
        else
            if (high > indicore3_ffi.stream_getPrice(ffi_parOp, period)) then
                indicore3_ffi.outputstreamimpl_set(ffi_position, period, 1);
                indicore3_ffi.outputstreamimpl_set(ffi_SAR, period, lastLowest);
                if indicore3_ffi.stream_getPrice(ffi_SAR, period) > low then
                     indicore3_ffi.outputstreamimpl_set(ffi_SAR, period, low);
                end
                 indicore3_ffi.outputstreamimpl_set(ffi_tradeHigh, period, high);
                 indicore3_ffi.outputstreamimpl_set(ffi_tradeLow, period, low);
                 indicore3_ffi.outputstreamimpl_set(ffi_af, period, init);
                 indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, indicore3_ffi.stream_getPrice(ffi_SAR, period) +
                                                    indicore3_ffi.stream_getPrice(ffi_af, period) * 
                                                    (indicore3_ffi.stream_getPrice(ffi_tradeHigh, period) -
                                                    indicore3_ffi.stream_getPrice(ffi_SAR, period)));
                if (indicore3_ffi.stream_getPrice(ffi_parOp, period) > low) then
                    indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, low);
                end
                if (indicore3_ffi.stream_getPrice(ffi_parOp, period) > prevLow) then
                    indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, prevLow);
                end
            else
                indicore3_ffi.outputstreamimpl_set(ffi_SAR,
                                                   period,
                                                   indicore3_ffi.stream_getPrice(ffi_parOp, period));

                if (period > 1 and indicore3_ffi.stream_getPrice(ffi_tradeLow, period) < indicore3_ffi.stream_getPrice(ffi_tradeLow, period - 1) and 
                    indicore3_ffi.stream_getPrice(ffi_af, period) < maxVal) then
                    indicore3_ffi.outputstreamimpl_set(ffi_af, period, indicore3_ffi.stream_getPrice(ffi_af, period) + quant);
                    if indicore3_ffi.stream_getPrice(ffi_af, period) > maxVal then
                        indicore3_ffi.outputstreamimpl_set(ffi_af, period, maxVal);
                    end
                end

                indicore3_ffi.outputstreamimpl_set(ffi_parOp,
                                                   period,
                                                   indicore3_ffi.stream_getPrice(ffi_SAR,period) + 
                                                   indicore3_ffi.stream_getPrice(ffi_af,period) * 
                                                   (indicore3_ffi.stream_getPrice(ffi_tradeLow,period) - 
                                                   indicore3_ffi.stream_getPrice(ffi_SAR,period)));

                if (indicore3_ffi.stream_getPrice(ffi_parOp, period) < high) then
                    indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, high);
                end
                if (indicore3_ffi.stream_getPrice(ffi_parOp, period) < prevHigh) then
                    indicore3_ffi.outputstreamimpl_set(ffi_parOp, period, prevHigh);
                end

            end
        end

        if indicore3_ffi.stream_getPrice(ffi_position, period) == 1 then
            indicore3_ffi.outputstreamimpl_set(ffi_DOWN, period, indicore3_ffi.stream_getPrice(ffi_SAR, period));
        else
            indicore3_ffi.outputstreamimpl_set(ffi_UP, period, indicore3_ffi.stream_getPrice(ffi_SAR, period));
        end
    end
end

else

function Update(period)
   local init = Step;
    local quant = Step;
    local maxVal = Max;
    local lastHighest = 0;
    local lastLowest = 0;
    local high = 0;
    local low = 0;
    local prevHigh = 0;
    local prevLow = 0;
    if period >= first then
        high = source.high[period];
        low = source.low[period];
        prevHigh = source.high[period - 1];
        prevLow = source.low[period - 1];
        if (period == first) then
            tradeHigh[period] = prevHigh;
            tradeLow[period] = prevLow;
            position[period] = -1;
            parOp[period] = prevHigh;
            af[period] = 0;
        else
            parOp[period] = parOp[period - 1];
            position[period] = position[period - 1];
            tradeHigh[period] = tradeHigh[period - 1];
            tradeLow[period] = tradeLow[period - 1];
            af[period] = af[period - 1];
        end
        lastHighest = tradeHigh[period];
        lastLowest = tradeLow[period];
        if high > lastHighest then
            tradeHigh[period] = high;
        end
        if low < lastLowest then
            tradeLow[period] = low;
        end
        if position[period] == 1 then
            if (low < parOp[period]) then
                position[period] = -1;
                SAR[period] = lastHighest;
                if SAR[period] < high then
                    SAR[period] = high;
                end
                tradeHigh[period] = high;
                tradeLow[period] = low;
                af[period] = init;
                parOp[period] = SAR[period] + af[period] * (tradeLow[period] - SAR[period]);
                if (parOp[period] < high) then
                    parOp[period] = high;
                end
                if (parOp[period] < prevHigh) then
                    parOp[period] = prevHigh;
                end
            else
                SAR[period] = parOp[period];
                if (tradeHigh[period] > tradeHigh[period - 1] and af[period] < maxVal) then
                    af[period] = af[period] + quant;
                    if af[period] > maxVal then
                        af[period] = maxVal;
                    end
                end

                parOp[period] = SAR[period] + af[period] * (tradeHigh[period] - SAR[period]);
                if (parOp[period] > low) then
                    parOp[period] = low;
                end
                if (parOp[period] > prevLow) then
                    parOp[period] = prevLow;
                end
            end
        else
            if (high > parOp[period]) then
                position[period] = 1;
                SAR[period] = lastLowest;
                if SAR[period] > low then
                    SAR[period] = low;
                end
                tradeHigh[period] = high;
                tradeLow[period] = low;
                af[period] = init;
                parOp[period] = SAR[period] + af[period] * (tradeHigh[period] - SAR[period]);
                if (parOp[period] > low) then
                    parOp[period] = low;
                end
                if (parOp[period] > prevLow) then
                    parOp[period] = prevLow;
                end
            else
                SAR[period] = parOp[period];
                if (period > 1 and tradeLow[period] < tradeLow[period - 1] and af[period] < maxVal) then
                    af[period] = af[period] + quant;
                    if af[period] > maxVal then
                        af[period] = maxVal;
                    end
                end

                parOp[period] = SAR[period] + af[period] * (tradeLow[period] - SAR[period]);
                if (parOp[period] < high) then
                    parOp[period] = high;
                end
                if (parOp[period] < prevHigh) then
                    parOp[period] = prevHigh;
                end
            end
        end

        if position[period] == 1 then
            DOWN[period] = SAR[period];
        else
            UP[period] = SAR[period];
        end
    end
end



end
