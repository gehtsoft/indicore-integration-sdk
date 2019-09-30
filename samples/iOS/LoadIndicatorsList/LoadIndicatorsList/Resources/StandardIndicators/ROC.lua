-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 10 "Volume, Open Interest, and Breadth" (page 240-241)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrROC", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_ROC_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthROC", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_ROC_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleROC", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_ROC_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleROC", core.FLAG_LEVEL_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local first;
local source = nil;

if ffi then 
    local ffi_source;
    local ffi_ROC;
end


-- Streams block
local ROC = nil;

-- Routine
function Prepare()
    n = instance.parameters.N;
    source = instance.source;
    first = source:first() + n + 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    ROC = instance:addStream("ROC", core.Line, name, "ROC", instance.parameters.clrROC, first)
    ROC:setWidth(instance.parameters.widthROC);
    ROC:setStyle(instance.parameters.styleROC);
    local precision = math.max(2, source:getPrecision());
    ROC:setPrecision(precision);

    if ffi then
        -- following two lines are critcally important for the performance. comment and see how FFI will
        -- work even slover than a regular Lua code :-)
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_ROC = ffi.cast(pv, ROC.ffi_ptr);
    end
end

-- Indicator calculation routine
if ffi then

function Update(period)
    if period >= first then
       indicore3_ffi.outputstreamimpl_set(ffi_ROC, 
                                          period, 
                                          (indicore3_ffi.stream_getPrice(ffi_source, period) /
                                          indicore3_ffi.stream_getPrice(ffi_source, period - n) - 1) * 100);
    end
end

else

function Update(period)
    if period >= first then
       ROC[period] = (source[period] / source[period - n] - 1) * 100;
   
    end
end

end