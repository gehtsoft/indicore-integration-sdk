-- initializes the indicator
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"))
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Bill Williams");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("JawN", resources:get("param_JawN_name"), resources:get("param_JawN_description"), 13, 1, 300);
    indicator.parameters:addInteger("JawS", resources:get("param_JawS_name"), resources:get("param_JawS_description"), 8, 0, 300);

    indicator.parameters:addInteger("TeethN", resources:get("param_TeethN_name"), resources:get("param_TeethN_description"), 8, 1, 300);
    indicator.parameters:addInteger("TeethS", resources:get("param_TeethS_name"), resources:get("param_TeethS_description"), 5, 0, 300);

    indicator.parameters:addInteger("LipsN", resources:get("param_LipsN_name"), resources:get("param_LipsN_description"), 5, 1, 300);
    indicator.parameters:addInteger("LipsS", resources:get("param_LipsS_name"), resources:get("param_LipsS_description"), 3, 0, 300);

    indicator.parameters:addString("MTH", resources:get("param_MTH_name"), resources:get("param_MTH_description"), "SMMA");
    indicator.parameters:addStringAlternative("MTH", resources:get("string_alternative_MTH_MVA"), "", "MVA");
    indicator.parameters:addStringAlternative("MTH", resources:get("string_alternative_MTH_EMA"), "", "EMA");
    indicator.parameters:addStringAlternative("MTH", resources:get("string_alternative_MTH_LWMA"), "", "LWMA");
    indicator.parameters:addStringAlternative("MTH", resources:get("string_alternative_MTH_LSMA"), "", "REGRESSION");
    indicator.parameters:addStringAlternative("MTH", resources:get("string_alternative_MTH_SMMA"), "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", resources:get("string_alternative_MTH_Vidya1995"), "", "VIDYA");
    indicator.parameters:addStringAlternative("MTH", resources:get("string_alternative_MTH_Vidya1992"), "", "VIDYA92");
    indicator.parameters:addStringAlternative("MTH", resources:get("string_alternative_MTH_Wilders"), "", "WMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Display", resources:get("param_Display_name"), resources:get("param_Display_description"), "H");
    indicator.parameters:addStringAlternative("Display", resources:get("string_alternative_Display_Line"), "", "L");
    indicator.parameters:addStringAlternative("Display", resources:get("string_alternative_Display_Histogram"), "", "H");
    indicator.parameters:addColor("GrowColor", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_Grow_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_Grow_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("GrowWidth", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_Grow_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_Grow_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("GrowStyle", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_Grow_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_Grow_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("GrowStyle", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("FallColor", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_Fall_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_Fall_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("FallWidth", string.format(resources:get("R_width_of_PARAM_name"), resources:get("param_Fall_line_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("param_Fall_line_desc")), 1, 1, 5);
    indicator.parameters:addInteger("FallStyle", string.format(resources:get("R_style_of_PARAM_name"), resources:get("param_Fall_line_name")), 
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("param_Fall_line_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("FallStyle", core.FLAG_LEVEL_STYLE);

end

local source;
local first;
local alligator;
local jaws, teeth, lips;
local UP, DOWN;
local line;
local Ufirst, Uextent;
local Dfirst, Dextent;
local CG, CF;

if ffi then
    local ffi_source;
    local ffi_UP;
    local ffi_DOWN;
    local ffi_alligator;
end

function Prepare()
    assert(core.indicators:findIndicator(instance.parameters.MTH) ~= nil, resources:get("assert_MTHInstalled1") .. instance.parameters.MTH .. resources:get("assert_MTHInstalled2"));
    assert(core.indicators:findIndicator("ALLIGATOR") ~= nil, resources:get("assert_ALLIGATORInstalled"));
    line = (instance.parameters.Display ~= "H");
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.JawN .. "(" .. instance.parameters.JawS .. ")," .. instance.parameters.TeethN .. "(" .. instance.parameters.TeethS .. ")," .. instance.parameters.LipsN .. "(" .. instance.parameters.LipsS .. ")," .. instance.parameters.MTH .. ")";
    instance:name(name);

    local aprof, aparams;
    aprof = core.indicators:findIndicator("ALLIGATOR");
    aparams = aprof:parameters();

    aparams:setInteger("JawN", instance.parameters.JawN);
    aparams:setInteger("JawS", instance.parameters.JawS);
    aparams:setInteger("TeethN", instance.parameters.TeethN);
    aparams:setInteger("TeethS", instance.parameters.TeethS);
    aparams:setInteger("LipsN", instance.parameters.LipsN);
    aparams:setInteger("LipsS", instance.parameters.LipsS);
    aparams:setString("MTH", instance.parameters.MTH);
    alligator = aprof:createInstance(source, aparams);
    jaws = alligator:getStream(0);
    teeth = alligator:getStream(1);
    lips = alligator:getStream(2);

    Uextent = math.min(instance.parameters.JawS, instance.parameters.TeethS);
    Ufirst = math.max(jaws:first(), teeth:first());
    Dextent = math.min(instance.parameters.TeethS, instance.parameters.LipsS);
    Dfirst = math.max(lips:first(), teeth:first());

    local mode;
    if line then
        mode = core.Line;
    else
        mode = core.Bar;
    end

    UP = instance:addStream("UP", mode, name .. ".UP", "UP", instance.parameters.GrowColor, Ufirst, Uextent);
    DOWN = instance:addStream("DOWN", mode, name .. ".DN", "DN", instance.parameters.FallColor, Dfirst, Dextent);
    if line then
        UP:setWidth(instance.parameters.GrowWidth);
        UP:setStyle(instance.parameters.GrowStyle);
        DOWN:setWidth(instance.parameters.FallWidth);
        DOWN:setStyle(instance.parameters.FallStyle);
    end
    CG = instance.parameters.GrowColor;
    CF = instance.parameters.FallColor;

    if ffi then
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);
        ffi_UP = ffi.cast(pv, UP.ffi_ptr);
        ffi_DOWN = ffi.cast(pv, DOWN.ffi_ptr);
        ffi_alligator = ffi.cast(pv, alligator.ffi_ptr);        
    end

end

if ffi then

function Update(period, mode)

    if  mode == core.UpdateAll then
        indicore3_ffi.indicatorinstance_updateAll(ffi_alligator);
    elseif mode == core.UpdateNew then
            indicore3_ffi.indicatorinstance_update(ffi_alligator, false);
        else
            indicore3_ffi.indicatorinstance_update(ffi_alligator, true);		
    end
    
    local p;

    if period >= Ufirst - Uextent then
        p = period + Uextent;
        local absJT = jaws[p] - teeth[p];

        if absJT < 0 then
          absJT = -absJT;        
        end

        indicore3_ffi.outputstreamimpl_set(ffi_UP, p, absJT);
        if p > Ufirst then
            if indicore3_ffi.stream_getPrice(ffi_UP, p) > indicore3_ffi.stream_getPrice(ffi_UP,p - 1) then
               indicore3_ffi.outputstreamimpl_setColor(ffi_UP, p, CG);
            elseif indicore3_ffi.stream_getPrice(ffi_UP, p) < indicore3_ffi.stream_getPrice(ffi_UP,p - 1) then
               indicore3_ffi.outputstreamimpl_setColor(ffi_UP, p, CF);
            else
               indicore3_ffi.outputstreamimpl_setColor(ffi_UP, p, indicore3_ffi.outputstream_getColor(ffi_UP,p - 1));
            end
        end
    end

    if period >= Dfirst - Dextent then
        p = period + Dextent;

        local absTL = teeth[p] - lips[p];

        if absTL < 0 then
          absTL = -absTL;        
        end

        indicore3_ffi.outputstreamimpl_set(ffi_DOWN, p, -absTL);

        if p > Dfirst then
            if indicore3_ffi.stream_getPrice(ffi_DOWN, p) < indicore3_ffi.stream_getPrice(ffi_DOWN, p - 1) then
                indicore3_ffi.outputstreamimpl_setColor(ffi_DOWN, p, CG);
            elseif indicore3_ffi.stream_getPrice(ffi_DOWN, p) > indicore3_ffi.stream_getPrice(ffi_DOWN, p - 1) then
                indicore3_ffi.outputstreamimpl_setColor(ffi_DOWN, p, CF);
            else
                indicore3_ffi.outputstreamimpl_setColor(ffi_DOWN, p, indicore3_ffi.outputstream_getColor(ffi_DOWN, p - 1));
            end
        end
    end

end

else

function Update(period, mode)
    alligator:update(mode);
    local p;

    if period >= Ufirst - Uextent then
        p = period + Uextent;
        UP[p] = math.abs(jaws[p] - teeth[p]);
        if p > Ufirst then
            if UP[p] > UP[p - 1] then
                UP:setColor(p, CG);
            elseif UP[p] < UP[p - 1] then
                UP:setColor(p, CF);
            else
                UP:setColor(p, UP:colorI(p - 1));
            end
        end
    end

    if period >= Dfirst - Dextent then
        p = period + Dextent;
        DOWN[p] = -math.abs(teeth[p] - lips[p]);

        if p > Dfirst then
            if DOWN[p] < DOWN[p - 1] then
                DOWN:setColor(p, CG);
            elseif DOWN[p] > DOWN[p - 1] then
                DOWN:setColor(p, CF);
            else
                DOWN:setColor(p, DOWN:colorI(p - 1));
            end
        end
    end
end

end