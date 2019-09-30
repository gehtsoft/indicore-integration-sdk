function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
    indicator:setTag("replaceSource", "t");
end

local source = nil;

local open = nil;
local high = nil;
local low = nil;
local close = nil;

if ffi then 
    local ffi_source;
    local ffi_open;
    local ffi_high;
    local ffi_low;
    local ffi_close;
    local ffi_source_open;
    local ffi_source_close;
    local ffi_source_low;
    local ffi_source_high;
end

local first = 0;

-- Routine
function Prepare()
    source = instance.source;
    first = source:first() + 1;

    local name = profile:id() .. "(" .. source:name() .. ")";

    instance:name(name);
    local stream_color = core.host:execute("getProperty", "LabelColor");
    open = instance:addStream("open", core.Line, name .. ".open", "open", stream_color, first)
    high = instance:addStream("high", core.Line, name .. ".high", "high", stream_color, first)
    low = instance:addStream("low", core.Line, name .. ".low", "low", stream_color, first)
    close = instance:addStream("close", core.Line, name .. ".close", "close", stream_color, first)
    instance:createCandleGroup(name, "HA", open, high, low, close);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_open = ffi.cast(pv, open.ffi_ptr);
        ffi_high = ffi.cast(pv, high.ffi_ptr);
        ffi_low = ffi.cast(pv, low.ffi_ptr);
        ffi_close = ffi.cast(pv, close.ffi_ptr);
        ffi_source_open = ffi.cast(pv, source.open.ffi_ptr);
        ffi_source_close = ffi.cast(pv, source.close.ffi_ptr);
        ffi_source_low = ffi.cast(pv, source.low.ffi_ptr);
        ffi_source_high = ffi.cast(pv, source.high.ffi_ptr);
    end

end

-- Indicator calculation routine
if ffi then

function math_max(val1, val2, val3) 

  if val1 > val2 then
      if val1 > val3 then
          return val1;
      else
          return val3;
      end
  elseif val2 > val3 then
      return val2;
  else
      return val3;
  end

end

function math_min(val1, val2, val3) 

  if val1 < val2 then
      if val1 < val3 then
          return val1;
      else
          return val3;
      end
  elseif val2 < val3 then
      return val2;
  else
      return val3;
  end

end

function Update(period)
    if period >= first then
        if (period == first) then
            indicore3_ffi.outputstreamimpl_set(ffi_open,
                                               period,
                                               (indicore3_ffi.stream_getPrice(ffi_source_open, period - 1) +
                                               indicore3_ffi.stream_getPrice(ffi_source_close, period - 1)) / 2);
        else
            open[period] = (open[period - 1] + close[period - 1]) / 2;
        end
        indicore3_ffi.outputstreamimpl_set(ffi_close,
                                           period,
                                           (indicore3_ffi.stream_getPrice(ffi_source_open, period) +
                                           indicore3_ffi.stream_getPrice(ffi_source_high, period) +
                                           indicore3_ffi.stream_getPrice(ffi_source_low, period) +
                                           indicore3_ffi.stream_getPrice(ffi_source_close, period)) / 4);
        indicore3_ffi.outputstreamimpl_set(ffi_high,
                                           period,
                                           math_max(open[period], close[period], source.high[period]));
        indicore3_ffi.outputstreamimpl_set(ffi_low,
                                           period,
                                           math_min(open[period], close[period], source.low[period]));
    end
end

else

function Update(period, mode)
    if period >= first then
        if (period == first) then
            open[period] = (source.open[period - 1] + source.close[period - 1]) / 2;
        else
            open[period] = (open[period - 1] + close[period - 1]) / 2;
        end
        close[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
        high[period] = math.max(open[period], close[period], source.high[period]);
        low[period] = math.min(open[period], close[period], source.low[period]);
    end
end

end