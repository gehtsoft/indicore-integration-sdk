-- The indicator corresponds to the ATR indicator in MetaTrader.

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volatility");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrATR", resources:get("R_line_color_name"), 
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_ATR_line_name")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthATR", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_ATR_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleATR", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_ATR_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleATR", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local tr = nil;
local trFirst = nil;
local tAbs = math.abs;

if ffi then
    local ffi_source;
    local ffi_ATR;
    local ffi_tr;
end

-- Streams block
local ATR = nil;

-- Routine
function Prepare()
    n = instance.parameters.N;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    tr = instance:addInternalStream(source:first() + 1, 0);
    first = tr:first() + n;
    ATR = instance:addStream("ATR", core.Line, name, "ATR", instance.parameters.clrATR, first)
    ATR:setWidth(instance.parameters.widthATR);
    ATR:setStyle(instance.parameters.styleATR);
    local precision = math.max(2, source:getPrecision());
    ATR:setPrecision(precision);
    trFirst = tr:first();

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_ATR = ffi.cast(pv, ATR.ffi_ptr);
		ffi_tr = ffi.cast(pv, tr.ffi_ptr);
    end
 
end

function getTrueRange(period)
    local hl = tAbs(source.high[period] - source.low[period]);
    local hc = tAbs(source.high[period] - source.close[period - 1]);
    local lc = tAbs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

-- Indicator calculation routine
if ffi then

function Update(period)
    if period >= trFirst then
        indicore3_ffi.outputstreamimpl_set(ffi_tr, period, getTrueRange(period));
    end
    if period >= first then
       indicore3_ffi.outputstreamimpl_set(ffi_ATR,
                                          period,
                                          indicore3_ffi.core_math_avg(ffi_tr, period - n + 1, period));
    end
end

else

function Update(period)
    if period >= trFirst then
        tr[period] = getTrueRange(period);
    end
    if period >= first then
        ATR[period] = mathex.avg(tr, period - n + 1, period);
    end
end


end