-- EMA's reduce the lag by applying more weight to recent prices relative to older prices.
-- The formula for an exponential moving average is:
-- EMA(current) = ( (Price(current) - EMA(prev) ) x Multiplier) + EMA(prev)
-- For a period-based EMA, "Multiplier" is equal to 2 / (1 + N)
-- The indicator corresponds to the Moving Average indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 4 "Trend Calculations" (page 68-70)

-- initializes the indicator
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Moving Averages");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 10, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrEMA", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_EMA_line_name")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthEMA", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_EMA_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleEMA", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_EMA_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleEMA", core.FLAG_LEVEL_STYLE);
end

local first1 = 0;
local first = 0;
local n = 0;
local k = 0;
local source = nil;
local out = nil;
local internal;

if ffi then
    local ffi_source;
    local ffi_output;
    local ffi_internal;
end

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    n = instance.parameters.N;
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    k = 2.0 / (n + 1.0);
    first1 = source:first();
    first = source:first() + math.floor(n * 1.5);

    internal = instance:addInternalStream(0, 0);
    out = instance:addStream("EMA", core.Line, name, "EMA", instance.parameters.clrEMA,  first)
    out:setWidth(instance.parameters.widthEMA);
    out:setStyle(instance.parameters.styleEMA);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_output = ffi.cast(pv, out.ffi_ptr);
        ffi_internal = ffi.cast(pv, internal.ffi_ptr);
    end
end

-- calculate the value
if ffi then

function Update(period)
    if (period >= first1) then
        local value = 0;
        local sourcePeriod = indicore3_ffi.stream_getPrice(ffi_source, period);
        if (period == first1) then
            value = sourcePeriod;
        else
            value = indicore3_ffi.stream_getPrice(ffi_internal, period - 1);
        end
	    indicore3_ffi.outputstreamimpl_set(ffi_internal, period, (1 - k) * value + k * sourcePeriod);
    end

    if period >= first then
        indicore3_ffi.outputstreamimpl_set(ffi_output, period, indicore3_ffi.stream_getPrice(ffi_internal, period));
    end
end

else

function Update(period)
    if (period >= first1) then
        local value = 0;
        local sourcePeriod = source[period];
        if (period == first1) then
            value = sourcePeriod;
        else
            value = internal[period - 1];
        end
        internal[period] = (1 - k) * value + k * sourcePeriod;
    end

    if period >= first then
        out[period] = internal[period];
    end
end

end