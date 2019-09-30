-- MACD
-- Moving Average Convergence/Divergence
-- MACD uses moving averages, which are lagging indicators, to include
-- some trend-following characteristics. These lagging indicators are
-- turned into a momentum oscillator by subtracting the longer moving
-- average from the shorter moving average. The resulting plot forms a
-- line that oscillates above and below zero, without any upper or lower
-- limits.
-- The MACD produces three lines: MACD, SIGNAL and HISTOGRAM.
-- The classic formulae is:
-- MACD = EMA(price; 12) - EMA(price; 26)
-- SIGNAL = EMA(MACD; 9)
-- HISTOGRAM = MACD - SIGNAL

-- The indicator corresponds to the MACD indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 128-130)


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", resources:get("param_SN_name"), resources:get("param_SN_description"), 12, 2, 1000);
    indicator.parameters:addInteger("LN", resources:get("param_LN_name"), resources:get("param_LN_description"), 26, 2, 1000);
    indicator.parameters:addInteger("IN", resources:get("param_IN_name"), resources:get("param_IN_description"), 9, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_MACD_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_MACD_line_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthMACD", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_MACD_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_MACD_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleMACD", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_MACD_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_MACD_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleMACD", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("SIGNAL_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_SIGNAL_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_SIGNAL_line_desc")), core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSIGNAL", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_SIGNAL_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_SIGNAL_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleSIGNAL", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_SIGNAL_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_SIGNAL_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleSIGNAL", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("HISTOGRAM_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_HISTOGRAM_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_HISTOGRAM_line_desc")), core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local IN;

local firstPeriodMACD;

local firstPeriodSIGNAL;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;

if ffi then 
    local ffi_MACD;
    local ffi_SIGNAL;
    local ffi_HISTOGRAM;
    local ffi_EMAL;
    local ffi_EMAS;
    local ffi_MVAI;
    local ffi_EMAL_DATA;
    local ffi_EMAS_DATA;
    local ffi_MVAI_DATA;
end

-- Routine
function Prepare()
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;

    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

    -- Create short and long EMAs for the source
    EMAS = core.indicators:create("EMA", source, SN);
    EMAL = core.indicators:create("EMA", source, LN);

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);

    local precision = math.max(2, source:getPrecision());
    
    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
    MACD:setWidth(instance.parameters.widthMACD);
    MACD:setStyle(instance.parameters.styleMACD);
    MACD:setPrecision(precision);

    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("MVA", MACD, IN);
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();

    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNAL:setWidth(instance.parameters.widthSIGNAL);
    SIGNAL:setStyle(instance.parameters.styleSIGNAL);
    SIGNAL:setPrecision(precision);
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. ".HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_color, firstPeriodSIGNAL);
    HISTOGRAM:setPrecision(precision);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_MACD = ffi.cast(pv, MACD.ffi_ptr);
        ffi_SIGNAL = ffi.cast(pv, SIGNAL.ffi_ptr);
        ffi_HISTOGRAM = ffi.cast(pv, HISTOGRAM.ffi_ptr);
        ffi_EMAS = ffi.cast(pv, EMAS.ffi_ptr);
        ffi_EMAL = ffi.cast(pv, EMAL.ffi_ptr);
        ffi_MVAI = ffi.cast(pv, MVAI.ffi_ptr); 
        ffi_EMAS_DATA = ffi.cast(pv, EMAS.DATA.ffi_ptr);
        ffi_EMAL_DATA = ffi.cast(pv, EMAL.DATA.ffi_ptr);
        ffi_MVAI_DATA = ffi.cast(pv, MVAI.DATA.ffi_ptr); 
    end


end

-- Indicator calculation routine
if ffi then

function Update(period, mode)
    -- and update short and long EMAs for the source.
    
    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_EMAS);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_EMAS, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_EMAS, true);		
    end
    
    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_EMAL);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_EMAL, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_EMAL, true);		
    end
    
    if (period >= firstPeriodMACD) then
        -- calculate MACD output
        indicore3_ffi.outputstreamimpl_set(ffi_MACD,
                                           period,
                                           indicore3_ffi.stream_getPrice(ffi_EMAS_DATA, period) -
                                           indicore3_ffi.stream_getPrice(ffi_EMAL_DATA, period));
    end

   -- update MVA on the MACD
    
    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_MVAI);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_MVAI, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_MVAI, true);	
    end
    
    if (period >= firstPeriodSIGNAL) then
        indicore3_ffi.outputstreamimpl_set(ffi_SIGNAL, 
                                           period,
                                           indicore3_ffi.stream_getPrice(ffi_MVAI_DATA, period));
        -- calculate histogram as a difference between MACD and signal
        indicore3_ffi.outputstreamimpl_set(ffi_HISTOGRAM,
                                           period,
                                           indicore3_ffi.stream_getPrice(ffi_MACD, period) -
                                           indicore3_ffi.stream_getPrice(ffi_SIGNAL, period));
    end
end

else

function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);

    if (period >= firstPeriodMACD) then
        -- calculate MACD output
         MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
    end

    -- update MVA on the MACD
    MVAI:update(mode);
    if (period >= firstPeriodSIGNAL) then
        SIGNAL[period] = MVAI.DATA[period];
        -- calculate histogram as a difference between MACD and signal
        HISTOGRAM[period] = MACD[period] - SIGNAL[period];
    end
end

end