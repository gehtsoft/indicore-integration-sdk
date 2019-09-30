-- initializes the indicator
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Moving Averages");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 7, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_line_name")), core.rgb(192, 192, 131));
    indicator.parameters:addInteger("width", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("style", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local first = 0;
local n = 0;
local source = nil;
local out = nil;

if ffi then 
    local ffi_source;
    local ffi_output;
end


-- initializes the instance of the indicator
function Prepare()
    source = instance.source;
    n = instance.parameters.N;
    first = n + source:first() - 1;
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
    out = instance:addStream("SMMA", core.Line, name, "SMMA", instance.parameters.clr,  first)
    out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);

    if ffi then
        -- following two lines are critcally important for the performance. comment and see how FFI will
        -- work even slover than a regular Lua code :-)
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_out = ffi.cast(pv, out.ffi_ptr);

    end

end

-- calculate the value
if ffi then

function Update(period)	
    if (period == first) then
        indicore3_ffi.outputstreamimpl_set(ffi_out,
                                           period,
                                           indicore3_ffi.core_math_avg(ffi_source, period - n + 1, period));
   elseif (period > first) then
        indicore3_ffi.outputstreamimpl_set(ffi_out,
                                           period, 
                                           (indicore3_ffi.stream_getPrice(ffi_out, period - 1) * (n - 1) +
                                            indicore3_ffi.stream_getPrice(ffi_source, period)) / n);
    end
end

else

function Update(period)
    if (period == first) then
        out[period] = mathex.avg(source, period - n + 1, period);
    elseif (period > first) then
        out[period] = (out[period - 1] * (n - 1) + source[period]) / n;
    end
end

end