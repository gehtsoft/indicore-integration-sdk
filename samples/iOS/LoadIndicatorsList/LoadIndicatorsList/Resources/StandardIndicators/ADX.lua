-- The indicator corresponds to the ADX indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 23 "Risk Control" (page 609-611)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend Strength");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("R_number_of_periods_name"), resources:get("R_number_of_periods_desciption"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrADX", resources:get("R_line_color_name"),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_ADX_line_name")), core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthADX", resources:get("R_line_width_name"),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_ADX_line_name")), 1, 1, 5);
    indicator.parameters:addInteger("styleADX", resources:get("R_line_style_name"),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_ADX_line_name")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleADX", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local first, dmifirst;
local source = nil;
local buffer = nil;
local dmi = nil;
local ema = nil;

if ffi then 
    local ffi_source;
    local ffi_buffer;
    local ffi_ADX;
    local ffi_dmi;
    local ffi_ema;
    local ffi_DIP;
    local ffi_DIM;
    local ffi_ema_DATA;
end

-- Streams block
local ADX = nil;

-- Routine
function Prepare(onlyName)
    n = instance.parameters.N;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end


    dmi = core.indicators:create("DMI", source, n);
    dmifirst = dmi.DIP:first();

    buffer = instance:addInternalStream(dmifirst, 0);

    ema = core.indicators:create("EMA", buffer, n);
    first = ema.DATA:first();

    ADX = instance:addStream("ADX", core.Line, name, "ADX", instance.parameters.clrADX, first)
    ADX:setPrecision(2);
    ADX:setWidth(instance.parameters.widthADX);
    ADX:setStyle(instance.parameters.styleADX);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_buffer = ffi.cast(pv, buffer.ffi_ptr);
        ffi_ADX = ffi.cast(pv, ADX.ffi_ptr);
        ffi_dmi = ffi.cast(pv, dmi.ffi_ptr);
        ffi_ema = ffi.cast(pv, ema.ffi_ptr);
        ffi_DIP = ffi.cast(pv, dmi.DIP.ffi_ptr);
        ffi_DIM = ffi.cast(pv, dmi.DIM.ffi_ptr);
        ffi_ema_DATA = ffi.cast(pv, ema.DATA.ffi_ptr);
    end

end

-- Indicator calculation routine
if ffi then
function Update(period, mode)

    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_dmi);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_dmi, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_dmi, true);		
    end

    if period >= dmifirst then
        local plus = indicore3_ffi.stream_getPrice(ffi_DIP, period);
        local minus = indicore3_ffi.stream_getPrice(ffi_DIM, period);

        local div = plus + minus;
        if (div == 0) then
            indicore3_ffi.outputstreamimpl_set(ffi_buffer, period, 0);
        else
            local absPM = plus - minus

            if absPM < 0 then
                absPM = -absPM;
            end

            indicore3_ffi.outputstreamimpl_set(ffi_buffer, period, 100 * (absPM / div));
        end
    end

    if period >= first then
        
    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_ema);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_ema, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_ema, true);		
    end

        indicore3_ffi.outputstreamimpl_set(ffi_ADX,
                                           period,
                                           indicore3_ffi.stream_getPrice(ffi_ema_DATA, period));
    end
end

else

function Update(period, mode)
    dmi:update(mode);

    if period >= dmifirst then
        local plus = dmi.DIP[period];
        local minus = dmi.DIM[period];

        local div = plus + minus;
        if (div == 0) then
            buffer[period] = 0;
        else
            buffer[period] = 100 * (math.abs(plus - minus) / div)
        end
    end

    if period >= first then
        ema:update(mode);
        ADX[period] = ema.DATA[period];
    end
end



end