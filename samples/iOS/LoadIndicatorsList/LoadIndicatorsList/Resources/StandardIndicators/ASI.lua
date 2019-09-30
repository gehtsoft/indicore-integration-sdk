-- http://ta.mql4.com/indicators/trends/accumulation_swing

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Swing");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("T", resources:get("param_T_name"), resources:get("param_T_description"), 300, 2, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrASI", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_ASI_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthASI", resources:get("R_line_width_name"), 
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_ASI_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleASI", resources:get("R_line_style_name"), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_ASI_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleASI", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;

-- Streams block
local SI = nil;
local ASI=nil;
local T = nil;

if ffi then
    local ffi_source;
    local ffi_ASI
    local ffi_source_high;
    local ffi_source_low
    local ffi_open;
    local ffi_close;
end

-- Routine
function Prepare()

    source = instance.source;
    first = source:first() + 1;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    ASI = instance:addStream("ASI", core.Line, name, "ASI", instance.parameters.clrASI, first);
    ASI:setWidth(instance.parameters.widthASI);
    ASI:setStyle(instance.parameters.styleASI);
    local precision = math.max(2, source:getPrecision());
    ASI:setPrecision(precision);
    T = source:pipSize() * instance.parameters.T;

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_source_open = ffi.cast(pv, source.open.ffi_ptr);
        ffi_source_close = ffi.cast(pv, source.close.ffi_ptr);
        ffi_source_high = ffi.cast(pv, source.high.ffi_ptr);
        ffi_source_low = ffi.cast(pv, source.low.ffi_ptr);

        ffi_ASI = ffi.cast(pv, ASI.ffi_ptr);             
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

function Update(period)

    if period >= first then
        local nom = indicore3_ffi.stream_getPrice(ffi_source_close, period) - 
                    indicore3_ffi.stream_getPrice(ffi_source_close, period - 1) +
                    (0.5 * (indicore3_ffi.stream_getPrice(ffi_source_close, period) - 
                     indicore3_ffi.stream_getPrice(ffi_source_open, period))) +
                    (0.25 * (indicore3_ffi.stream_getPrice(ffi_source_close, period - 1) - 
                    indicore3_ffi.stream_getPrice(ffi_source_open, period - 1)));


        local closePrev = indicore3_ffi.stream_getPrice(ffi_source_close, period - 1);
        local highCurr = indicore3_ffi.stream_getPrice(ffi_source_high, period);
        local lowCurr = indicore3_ffi.stream_getPrice(ffi_source_low, period);


        local hc = highCurr - closePrev;
	if hc < 0 then
	   hc = -hc;
	end
	
        local lc = lowCurr - closePrev;
	if lc < 0 then
	   lc = -lc;
	end
        
        local hl = highCurr - lowCurr;
	if hl < 0 then
	   hl = -hl;
        end
        
      		
        local co = closePrev - indicore3_ffi.stream_getPrice(ffi_source_open, period - 1);
	if co < 0 then
           co = -co;	
	end

        local TR = math_max(hc, lc, hl);

        local ER = 0;

        if (closePrev > highCurr) then
            ER = hc;
        elseif (closePrev < lowCurr) then
            ER = lc;
        else
            ER = 0
        end

        local SH = co;
         
        local K = hc;

        if hc < lc then 
           K = lc           
        end  

        local R = TR - 0.5 * ER + 0.25 * SH;

        if (R == 0) then
            SI = 0;
        else
            SI = 50 * nom * (K / T) / R;
        end

        if (period == first) then
            ASI[period] = SI;
        else
            ASI[period] = ASI[period - 1] + SI;
        end


        if (period == first) then
            indicore3_ffi.outputstreamimpl_set(ffi_ASI,
                                               period,
                                               SI);

        else
            indicore3_ffi.outputstreamimpl_set(ffi_ASI,
                                               period,
                                               indicore3_ffi.stream_getPrice(ffi_ASI, period - 1) + SI);
        end


        indicore3_ffi.outputstreamimpl_set(ffi_ASI,
                                           period,
                                           indicore3_ffi.stream_getPrice(ffi_ASI, period - 1) + SI);
 
    end
end

else

function Update(period)
    local open, close, abs;

    if period >= first then
        open = source.open;
        close = source.close;
        abs = math.abs

        local nom = close[period] - close[period - 1]
            + (0.5 * (close[period] - open[period]))
            + (0.25 * (close[period - 1] - open[period - 1]));


        local closePrev = close[period - 1];
        local highCurr = source.high[period];
        local lowCurr = source.low[period];
        local hc = abs(highCurr - closePrev);
        local lc = abs(lowCurr - closePrev);
        local hl = abs(highCurr - lowCurr);
        local co = abs(closePrev - open[period - 1]);

        local TR = math.max(hc, lc, hl);

        local ER = 0;

        if (closePrev > highCurr) then
            ER = hc;
        elseif (closePrev < lowCurr) then
            ER = lc;
        else
            ER = 0
        end

        local SH = co;
        local K = math.max(hc, lc);
        local R = TR - 0.5 * ER + 0.25 * SH;

        if (R == 0) then
            SI = 0;
        else
            SI = 50 * nom * (K / T) / R;
        end

        if (period == first) then
            ASI[period] = SI;
        else
            ASI[period] = ASI[period - 1] + SI;
        end

    end
end


end