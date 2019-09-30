function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Bill Williams");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FM", resources:get("param_FM_name"), resources:get("param_FM_description"), 5, 2, 10000);
    indicator.parameters:addInteger("SM", resources:get("param_SM_name"), resources:get("param_SM_description"), 35, 2, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("GO_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_GO_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_GO_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addColor("RO_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_RO_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_RO_desc")), core.rgb(255, 0, 0));
end

local FM;
local SM;

local first;
local source = nil;

-- Streams block
local CL = nil;

local FMVA = nil;
local SMVA = nil;
local GO, RO;

if ffi then
   local ffi_source;
   local ffi_FMVA;
   local ffi_SMVA;

   local ffi_FMVA_DATA;
   local ffi_SMVA_DATA;
   local ffi_CL;
end

function Prepare()
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;

    assert(FM < SM, resources:get("assert_FMLessSM"));

    source = instance.source;
    first = source:first() + SM;

    -- Create the median stream
    FMVA = core.indicators:create("MVA", source.median, FM);
    SMVA = core.indicators:create("MVA", source.median, SM);

    local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ")";
    instance:name(name);
    CL = instance:addStream("AO", core.Bar, name .. ".AO", "AO", instance.parameters.GO_color, first);
    CL:addLevel(0);
    GO = instance.parameters.GO_color;
    RO = instance.parameters.RO_color;
		
    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_FMVA = ffi.cast(pv, FMVA.ffi_ptr);
        ffi_SMVA = ffi.cast(pv, SMVA.ffi_ptr);
        ffi_CL = ffi.cast(pv, CL.ffi_ptr);
        ffi_FMVA_DATA = ffi.cast(pv, FMVA.DATA.ffi_ptr);
        ffi_SMVA_DATA = ffi.cast(pv, SMVA.DATA.ffi_ptr);
    end
end

if ffi then
function Update(period, mode)
    --FMVA:update(mode);
    if  mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_FMVA);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_FMVA, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_FMVA, true);		
    end
    --SMVA:update(mode);
    if  mode == core.UpdateAll then
            indicore3_ffi.indicatorinstance_updateAll(ffi_SMVA);
    elseif mode == core.UpdateNew then
            indicore3_ffi.indicatorinstance_update(ffi_SMVA, false);
        else
            indicore3_ffi.indicatorinstance_update(ffi_SMVA, true);		
    end
	
    if (period >= first) then
       indicore3_ffi.outputstreamimpl_set(ffi_CL, 
                                          period,
                                          indicore3_ffi.stream_getPrice(ffi_FMVA_DATA, period) - 
                                          indicore3_ffi.stream_getPrice(ffi_SMVA_DATA, period));
    end
	
    if (period >= first + 1) then
        if (indicore3_ffi.stream_getPrice(ffi_CL, period) > indicore3_ffi.stream_getPrice(ffi_CL, period - 1)) then
            indicore3_ffi.outputstreamimpl_setColor(ffi_CL, period, GO);
        elseif (indicore3_ffi.stream_getPrice(ffi_CL, period) < indicore3_ffi.stream_getPrice(ffi_CL, period - 1)) then
            indicore3_ffi.outputstreamimpl_setColor(ffi_CL, period, RO);
        else
            indicore3_ffi.outputstreamimpl_setColor(ffi_CL, period, indicore3_ffi.outputstream_getColor(ffi_CL, period - 1));
        end
    end

end

else 

function Update(period, mode)
    FMVA:update(mode);
    SMVA:update(mode);

    if (period >= first) then
        CL[period] = FMVA.DATA[period] - SMVA.DATA[period];
    end

    if (period >= first + 1) then
        if (CL[period] > CL[period - 1]) then
            CL:setColor(period, GO);
        elseif (CL[period] < CL[period - 1]) then
            CL:setColor(period, RO);
        else
            CL:setColor(period, CL:colorI(period - 1));
        end
    end
end

end