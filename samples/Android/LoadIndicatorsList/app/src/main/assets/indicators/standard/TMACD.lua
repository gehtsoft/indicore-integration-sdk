-- TMACD
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 8 "Cycle Analysis" (page 193-194)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", resources:get("param_SN_name"), resources:get("param_SN_description"), 7, 2, 1000);
    indicator.parameters:addInteger("LN", resources:get("param_LN_name"), resources:get("param_LN_description"), 14, 2, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrTMACD", resources:get("R_line_color_name"), 
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_TMACD_line_name")), core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;


local first;
local source = nil;
local SN = nil;
local LN = nil;

-- Streams block
local TMACD = nil;

if ffi then
    local ffi_source;
    local ffi_TMAS;
    local ffi_TMAL;
    local ffi_TMACD;
    local ffi_TMAL_DATA;
    local ffi_TMACD_DATA;
end

-- Routine
function Prepare()
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    source = instance.source;

    -- Check parameters
    if (LN <= SN) then
       error("The short TMA period must be smaller than long TMA period");
    end

    -- Create short and long TMAs for the source
    TMAS = core.indicators:create("TMA", source, SN);
    TMAL = core.indicators:create("TMA", source, LN);
    first = source:first() + math.max(TMAS.DATA:first(), TMAL.DATA:first());

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ")";
    instance:name(name);

    TMACD = instance:addStream("TMACD", core.Bar, name, "TMACD", instance.parameters.clrTMACD, first);
    local precision = math.max(2, source:getPrecision());
    TMACD:setPrecision(precision);

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_TMAS = ffi.cast(pv, TMAS.ffi_ptr);
        ffi_TMAL = ffi.cast(pv, TMAL.ffi_ptr);
        ffi_TMACD = ffi.cast(pv, TMACD.ffi_ptr);
        ffi_TMAS_DATA = ffi.cast(pv, TMAS.DATA.ffi_ptr);
        ffi_TMAL_DATA = ffi.cast(pv, TMAL.DATA.ffi_ptr);

    end

end

-- Indicator calculation routine
if ffi then
function Update(period, mode)

    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_TMAS);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_TMAS, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_TMAS, true);		
    end

    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_TMAL);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_TMAL, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_TMAL, true);		
    end

    if period >= first then
        indicore3_ffi.outputstreamimpl_set(ffi_TMACD,
                                           period,
                                           indicore3_ffi.stream_getPrice(ffi_TMAS_DATA, period) - 
                                           indicore3_ffi.stream_getPrice(ffi_TMAL_DATA, period));
    end

end

else
function Update(period, mode)
    TMAS:update(mode);
    TMAL:update(mode);
    if period >= first then
        TMACD[period] = TMAS.DATA[period] - TMAL.DATA[period];
    end
end


end