-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 17 "Adaptive Techniques" (page 440)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
    indicator:setTag("AllowAllSources", "y");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrARSI", resources:get("R_line_color_name"), 
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_ARSI_line_name")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthARSI", resources:get("R_line_width_name"), 
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_ARSI_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleARSI", resources:get("R_line_style_name"), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_ARSI_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleARSI", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local rsi = nil

if ffi then
    local ffi_source;
    local ffi_rsi;
    local ffi_ARSI;
end

-- Streams block
local ARSI = nil;

-- Routine
function Prepare()
    n = instance.parameters.N;
    if instance.source:isBar() then
        source = instance.source.close;
    else
        source = instance.source;
    end
    first = source:first() + n + 1;
    rsi = core.indicators:create("RSI", source, n);

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    ARSI = instance:addStream("ARSI", core.Line, name, "ARSI", instance.parameters.clrARSI, first)
    ARSI:setWidth(instance.parameters.widthARSI);
    ARSI:setStyle(instance.parameters.styleARSI);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_rsi = ffi.cast(pv, rsi.ffi_ptr);
        ffi_ARSI = ffi.cast(pv, ARSI.ffi_ptr);
        ffi_rsi_DATA = ffi.cast(pv, rsi.DATA.ffi_ptr);
       
    end

end

-- Indicator calculation routine
if ffi then

function Update(period, mode)
    if mode == core.UpdateAll then
       indicore3_ffi.indicatorinstance_updateAll(ffi_rsi);
    elseif mode == core.UpdateNew then
       indicore3_ffi.indicatorinstance_update(ffi_rsi, false);
    else
       indicore3_ffi.indicatorinstance_update(ffi_rsi, true);		
    end

    if period > first then
        local sc = indicore3_ffi.stream_getPrice(ffi_rsi_DATA, period) / 100;
       
        local absSc = sc - 0.5;
        if absSc < 0 then
          absSc = -absSc;        
        end

        sc = absSc * 2;
       
        local arsiPrev = indicore3_ffi.stream_getPrice(ffi_ARSI, period - 1);
        
        indicore3_ffi.outputstreamimpl_set(ffi_ARSI,
                                          period,
                                          arsiPrev + sc * (indicore3_ffi.stream_getPrice(ffi_source,period) - arsiPrev));    
    elseif period == first then
        indicore3_ffi.outputstreamimpl_set(ffi_ARSI,
                                          period,
                                          indicore3_ffi.stream_getPrice(ffi_source, period));
    end
end

else

function Update(period, mode)

    rsi:update(mode);
    if period > first then
        local sc = rsi.DATA[period] / 100;
        sc = math.abs(sc - 0.5) * 2;
        local arsiPrev = ARSI[period - 1];
        ARSI[period] = arsiPrev + sc * (source[period] - arsiPrev);    
    elseif period == first then
        ARSI[period] = source[period];
    end
end

end