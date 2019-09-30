function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bill Williams");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_UP_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_UP_line_desc")), core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_DN_line_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_DN_line_desc")), core.COLOR_DOWNCANDLE);
    indicator.parameters:addBoolean("ShowPrice", resources:get("param_show_price"), resources:get("param_show_price_1"), false);
    indicator.parameters:addColor("clrPrice", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_PRICE_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_PRICE_desc")), core.rgb(128, 128, 128));
end

local source;
local up, down;

if ffi then
    local ffi_source;
    local ffi_up;     
    local ffi_down;     
    local ffi_up1;
    local ffi_down1;
end


function Prepare()
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    up = instance:createTextOutput ("Up", "Up", "Wingdings", 9, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", 9, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
    up1 = instance:createTextOutput ("", "UpL", "Verdana", 7, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
    down1 = instance:createTextOutput ("", "DnL", "Verdana", 7, core.H_Right, core.V_Bottom, instance.parameters.clrPrice, 0);
    if ffi then        
        local pv = ffi.typeof("void *");
        ffi_source = ffi.cast(pv, source.ffi_ptr);     
        ffi_up = ffi.cast(pv, up.ffi_ptr);     
        ffi_down = ffi.cast(pv, down.ffi_ptr);     
        ffi_up1 = ffi.cast(pv, up1.ffi_ptr);
        ffi_down1 = ffi.cast(pv, down1.ffi_ptr);
    end

end

if ffi then

function Update(period, mode)
     if (period > 6) then
        local curr = indicore3_ffi.barstream_getHigh(ffi_source, period - 2);    
        if (curr > indicore3_ffi.barstream_getHigh(ffi_source, period - 4) and 
            curr > indicore3_ffi.barstream_getHigh(ffi_source, period - 3) and
            curr > indicore3_ffi.barstream_getHigh(ffi_source, period - 1) and 
            curr > indicore3_ffi.barstream_getHigh(ffi_source, period )) then
                indicore3_ffi.textoutputimpl_set(ffi_up,
                                                 period - 2,
                                                 indicore3_ffi.barstream_getHigh(ffi_source, period - 2),
                                                 "\217",
                                                 "" .. indicore3_ffi.barstream_getHigh(ffi_source, period - 2),
                                                 -1);

            if instance.parameters.ShowPrice then
                indicore3_ffi.textoutputimpl_set(ffi_up1,
                                                 period - 2,
                                                 indicore3_ffi.barstream_getHigh(ffi_source, period - 2),
                                                 " " .. indicore3_ffi.barstream_getHigh(ffi_source, period - 2),
                                                 0,
                                                 -1);
            end
        else
            indicore3_ffi.textoutputimpl_setNoData(ffi_up, period - 2);
            indicore3_ffi.textoutputimpl_setNoData(ffi_up1, period - 2);
        end
        curr = indicore3_ffi.barstream_getLow(ffi_source, period - 2);
        if (curr < indicore3_ffi.barstream_getLow(ffi_source, period - 4) and
            curr < indicore3_ffi.barstream_getLow(ffi_source, period - 3) and
            curr < indicore3_ffi.barstream_getLow(ffi_source, period - 1) and
            curr < indicore3_ffi.barstream_getLow(ffi_source, period)) then

            indicore3_ffi.textoutputimpl_set(ffi_down,
                                                 period - 2,
                                                 indicore3_ffi.barstream_getLow(ffi_source, period - 2),
                                                 "\218",
                                                 "" .. indicore3_ffi.barstream_getLow(ffi_source, period - 2),
                                                 -1);

            if instance.parameters.ShowPrice then
                indicore3_ffi.textoutputimpl_set(ffi_down1,
                                                 period - 2,
                                                 indicore3_ffi.barstream_getLow(ffi_source, period - 2),
                                                 "  " .. indicore3_ffi.barstream_getLow(ffi_source, period - 2),
                                                 0,
                                                 -1);
            end
        else
            indicore3_ffi.textoutputimpl_setNoData(ffi_down, period - 2);
            indicore3_ffi.textoutputimpl_setNoData(ffi_down1, period - 2);
        end
    end
end

else

function Update(period, mode)
    if (period > 6) then
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then
            up:set(period - 2, source.high[period - 2], "\217", source.high[period - 2]);
            if instance.parameters.ShowPrice then
                up1:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
        else
            up:setNoData(period - 2);
            up1:setNoData(period - 2);
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then
            down:set(period - 2, source.low[period - 2], "\218", source.low[period - 2]);
            if instance.parameters.ShowPrice then
                down1:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end
        else
            down:setNoData(period - 2);
            down1:setNoData(period - 2);
        end
    end
end

end
