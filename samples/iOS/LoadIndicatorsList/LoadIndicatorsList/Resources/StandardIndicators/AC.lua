function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Bill Williams");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FM", resources:get("param_FM_name"), resources:get("param_FM_description"), 5, 2, 10000);
    indicator.parameters:addInteger("SM", resources:get("param_SM_name"), resources:get("param_SM_description"), 35, 2, 10000);
    indicator.parameters:addInteger("M", resources:get("param_M_name"), resources:get("param_M_description"), 5, 2, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("GO_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_GO_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_GO_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addColor("RO_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_RO_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_RO_desc")), core.rgb(255, 0, 0));
end

local FM;
local SM;
local M;

local first;
local source = nil;

-- Streams block
local CL = nil;
local GO = nil;
local RO = nil;

local AO = nil;
local MVA = nil;

if ffi then 
    local ffi_source;
    local ffi_CL;		
    local ffi_MVA;
    local ffi_AO;
    local ffi_MVA_DATA;
    local ffi_AO_DATA;
end


function Prepare()
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    M = instance.parameters.M;

    source = instance.source;

    AO = core.indicators:create("AO", source, FM, SM);
    MVA = core.indicators:create("MVA", AO.DATA, M);
    first = MVA.DATA:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ", " .. M .. ")";
    instance:name(name);
    CL = instance:addStream("AC", core.Bar, name .. ".AC", "AC", instance.parameters.GO_color, first);
    CL:addLevel(0);
    GO = instance.parameters.GO_color;
    RO = instance.parameters.RO_color;
	
    if ffi then    
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_CL = ffi.cast(pv, CL.ffi_ptr);		
		ffi_MVA = ffi.cast(pv, MVA.ffi_ptr);
        ffi_AO = ffi.cast(pv, AO.ffi_ptr);
		ffi_MVA_DATA = ffi.cast(pv, MVA.DATA.ffi_ptr);
        ffi_AO_DATA = ffi.cast(pv, AO.DATA.ffi_ptr);		
    end
	
end

if ffi then

function Update(period, mode)
   
    if mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_AO);
    elseif mode == core.UpdateNew then
        indicore3_ffi.indicatorinstance_update(ffi_AO, false);
    else
        indicore3_ffi.indicatorinstance_update(ffi_AO, true);		
    end       


    if mode == core.UpdateAll then
       indicore3_ffi.indicatorinstance_updateAll(ffi_MVA);
    elseif mode == core.UpdateNew then
       indicore3_ffi.indicatorinstance_update(ffi_MVA, false);
    else
       indicore3_ffi.indicatorinstance_update(ffi_MVA, true);		
    end
	
    if (period >= first) then
       indicore3_ffi.outputstreamimpl_set(ffi_CL, period, AO.DATA[period] - MVA.DATA[period]);
    end
   
      
    if (period >= first + 1) then
        local curr, prev;
        curr = indicore3_ffi.stream_getPrice(ffi_CL, period);
        prev = indicore3_ffi.stream_getPrice(ffi_CL, period - 1);
        if (curr > prev) then
            indicore3_ffi.outputstreamimpl_setColor(ffi_CL, period, GO);
        elseif (curr < prev) then
            indicore3_ffi.outputstreamimpl_setColor(ffi_CL, period, RO);
        else
            indicore3_ffi.outputstreamimpl_setColor(ffi_CL, period, indicore3_ffi.outputstream_getColor(ffi_CL, period - 1));
        end
    end	
end

else

function Update(period, mode)
    AO:update(mode);
    MVA:update(mode);

    if (period >= first) then
        CL[period] = AO.DATA[period] - MVA.DATA[period];
    end
    
    if (period >= first + 1) then
        local curr, prev;
        curr = CL[period];
        prev = CL[period - 1];
        if (curr > prev) then
            CL:setColor(period, GO);
        elseif (curr < prev) then
            CL:setColor(period, RO);
        else
            CL:setColor(period, CL:colorI(period - 1));
        end
    end
end

end