function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup(resources:get("R_price_params_group"));
    indicator.parameters:addString("instrument", resources:get("R_instrument_name"), resources:get("R_instrument_desc"), "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("frame", resources:get("R_timeframe_name"), resources:get("R_timeframe_desc"), "H1");
    indicator.parameters:setFlag("frame", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", resources:get("R_pricetype_name"), resources:get("R_pricetype_desc"), true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addInteger("Step", resources:get("step_name"), resources:get("step_desc"), 100, 1, 1000);

    indicator.parameters:addGroup(resources:get("R_range_group"));
    indicator.parameters:addDate("from", resources:get("R_date_from_name"), resources:get("R_date_from_desc"), -1000);
    indicator.parameters:addDate("to", resources:get("R_date_to_name"), resources:get("R_date_to_desc"), 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);

    indicator.parameters:addGroup(resources:get("R_style_group"));
    indicator.parameters:addColor("up_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("up_trend_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("up_trend_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("up_width", string.format(resources:get("R_width_of_PARAM_name"), resources:get("up_trend_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("up_trend_desc")), 3, 1, 5);
    indicator.parameters:addColor("dn_color", string.format(resources:get("R_color_of_PARAM_name"), resources:get("dn_trend_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("dn_trend_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("dn_width", string.format(resources:get("R_width_of_PARAM_name"), resources:get("dn_trend_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("dn_trend_desc")), 1, 1, 5);
end

local loading;
local instrument;
local frame;
local StepPips;
local history;
local open, close;
local offer;
local offset;
local init;
local up_color, up_width, dn_color, dn_width;

if ffi then
    local ffi_context;
    local ffi_open;
    local ffi_close;
end 

-- initializes the instance of the indicator
function Prepare(onlyName)
    instrument = instance.parameters.instrument;
    frame = instance.parameters.frame;
    up_color = instance.parameters.up_color;
    up_width = instance.parameters.up_width;
    dn_color = instance.parameters.dn_color;
    dn_width = instance.parameters.dn_width;

    local name = profile:id() .. "(" .. instrument .. "." .. frame .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
    
    instance:ownerDrawn(true);

    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row;

    row = enum:next();
    while row ~= nil do
        if row.Instrument == instrument then
            break;
        end
        row = enum:next();
    end

    assert(row ~= nil, resources:get("R_error_instrument_not_found"));

    offer = row.OfferID;

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0);
    init = false;

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, frame, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    StepPips = instance.parameters.Step * history.close:pipSize();
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers");
    end
    core.host:execute("setStatus", resources:get("R_status_loading"));

    open = instance:addStream("open", core.Dot, name .. "." .. resources:get("R_open_price"), "open", up_color, 0, 0);
    close = instance:addStream("close", core.Dot, name .. "." .. resources:get("R_close_price"), "close", up_color, 0, 0);
    open:setVisible(false);
    close:setVisible(false); 

    if ffi then 
        local pv = ffi.typeof("void *");
        ffi_open = ffi.cast(pv, open.ffi_ptr);
        ffi_close = ffi.cast(pv, close.ffi_ptr);
    end

end

function Update(period, mode)
    -- shall never be called, ignore the call
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then
        if success then
            handleHistory();
            core.host:execute("setStatus", "");
        else
            core.host:trace("The indicator could not get the history");        
        end
    elseif cookie == 2000 then
        if message == offer then
            handleUpdate();
        end
    end
end

function calcValue(current, i)
    local source = history.close;
    if close[current] > open[current] then
        if source[i] > close[current] then
            close[current] = source[i];
        end
        if source[i] < close[current] - StepPips then
            current = current + 1;
            instance:addViewBar(source:date(i));
            open[current] = close[current - 1];
            close[current] = source[i];
        end
    end
    
    if close[current] < open[current] then
        if source[i] < close[current] then
            close[current] = source[i];
        end
        if source[i] > close[current] + StepPips then
            current = current + 1;
            instance:addViewBar(source:date(i));
            open[current] = close[current - 1];
            close[current] = source[i];
        end
    end
    return current;
end

function handleHistory()
    local s = history:size() - 1;
    local i;
    local current = open:size() - 1;
    local source = history.close;
    instance:addViewBar(source:date(0));
    open[current + 1] = source[0];

    for i = 1, s, 1 do        
        if current == -1 then
            if source[i] > open[current + 1] + StepPips then
                current = current + 1;
                close[current] = source[i];
            end
            if source[i] < open[current] - StepPips then
                current = current + 1;
                close[current] = source[i];
            end
        else 
            current = calcValue(current, i);
        end 
    end
    loading = false;
end

function handleUpdate()
    if not loading and history:size() > 0 then
        calcValue(open:size() - 1, history:size() - 1);
    end 
end

local UP_LINE_STYLE_ID = 1;
local DN_LINE_STYLE_ID = 2;

function isSwitchToUp(index)
    return index > 0 and open:hasData(index - 1) and open[index - 1] < close[index];
end

function isSwitchToDown(index)
    return index > 0 and open:hasData(index - 1) and open[index - 1] > close[index];
end

if ffi then 

function drawSection(context, current_color, open_price, close_price, x, x1, prevx, connectWithLastBar)
              
    local p1 = indicore3_ffi.odcontext_pointOfPrice(ffi_context, open_price);
    local p2 = indicore3_ffi.odcontext_pointOfPrice(ffi_context, close_price);

    indicore3_ffi.odcontext_drawLine(ffi_context, current_color, x, p1, x, p2, 0);
        
    if connectWithLastBar then
        if prevx == nil then
            indicore3_ffi.odcontext_drawLine(ffi_context, current_color, 2 * x1 - x, p1, x, p1, 0);
        else
            indicore3_ffi.odcontext_drawLine(ffi_context, current_color, prevx, p1, x, p1, 0);
        end
    end
end

function gerDirectionBefor(index)
    for i = index, 0, -1 do
        if indicore3_ffi.stream_getPrice(ffi_open, i) < indicore3_ffi.stream_getPrice(ffi_close, i) then
            if isSwitchToUp(i) then
                return UP_LINE_STYLE_ID;
            end
        else
            if isSwitchToDown(i) then
                return DN_LINE_STYLE_ID;
            end
        end
    end
    
    return UP_LINE_STYLE_ID;
end

function Draw(stage, context)

    local pv = ffi.typeof("void *");
    ffi_context = ffi.cast(pv, context.ffi_ptr);
  
    if stage == 0 then
       if not init then
            indicore3_ffi.odcontext_createPen(ffi_context, UP_LINE_STYLE_ID, context.SOLID, up_width, up_color);
            indicore3_ffi.odcontext_createPen(ffi_context, DN_LINE_STYLE_ID, context.SOLID, dn_width, dn_color);
            init = true;
        end
  
       local prevx;
        
       local firstBar = indicore3_ffi.odcontext_firstBar(ffi_context);
       local connectWithLastBar;
       local current_color = gerDirectionBefor(firstBar);
    
       indicore3_ffi.odcontext_setClipRectangle(ffi_context, 
                                                indicore3_ffi.odcontext_left(ffi_context), 
                                                indicore3_ffi.odcontext_top(ffi_context),
                                                indicore3_ffi.odcontext_right(ffi_context),
                                                indicore3_ffi.odcontext_bottom(ffi_context));

       indicore3_ffi.odcontext_startEnumeration(ffi_context);
       local nextBar = ffi.new("NEXT_BAR", 0, 0, 0, 0, 0, 0);
       while true do
            
            if indicore3_ffi.odcontext_nextBar(ffi_context, nextBar) == false then
                break;
            end
            local index = nextBar.index;
            local x = nextBar.x;
            local x1 = nextBar.x1;
            local x2 = nextBar.x2;
            local c1 = nextBar.c1;
            local c2 = nextBar.c2;
            if index ~= firstBar then
                connectWithLastBar = true;
            else
                connectWithLastBar = false;
            end
            
            local open_price = indicore3_ffi.stream_getPrice(ffi_open, index);
            local close_price = indicore3_ffi.stream_getPrice(ffi_close, index);
            if open_price < close_price then
                if current_color ~= UP_LINE_STYLE_ID and isSwitchToUp(index) then
                    drawSection(ffi_context, current_color, open_price, indicore3_ffi.stream_getPrice(ffi_open, index - 1), x, x1, prevx, connectWithLastBar);
                    current_color = UP_LINE_STYLE_ID;
                    open_price = indicore3_ffi.stream_getPrice(ffi_open, index - 1);
                    connectWithLastBar = false;
                end
            else
                if current_color ~= DN_LINE_STYLE_ID and isSwitchToDown(index) then
                    drawSection(ffi_context, current_color, open_price, indicore3_ffi.stream_getPrice(ffi_open, index - 1), x, x1, prevx, connectWithLastBar);
                    current_color = DN_LINE_STYLE_ID;
                    open_price = indicore3_ffi.stream_getPrice(ffi_open, index - 1);
                    connectWithLastBar = false;
                end
            end
           
            drawSection(ffi_context, current_color, open_price, close_price, x, x1, prevx, connectWithLastBar);
            prevx = x;
        end
        indicore3_ffi.odcontext_resetClipRectangle(ffi_context);
    end

end

else

function drawSection(context, current_color, open_price, close_price, x, x1, prevx, connectWithLastBar)
    m1, p1 = context:pointOfPrice(open_price);
    m2, p2 = context:pointOfPrice(close_price);
    
    context:drawLine(current_color, x, p1, x, p2);
    
    if connectWithLastBar then
        if prevx == nil then
            context:drawLine(current_color, 2 * x1 - x, p1, x, p1);
        else
            context:drawLine(current_color, prevx, p1, x, p1);
        end
    end
end


function gerDirectionBefor(index)
    for i = index, 0, -1 do
        if open[i] < close[i] then
            if isSwitchToUp(i) then
                return UP_LINE_STYLE_ID;
            end
        else
            if isSwitchToDown(i) then
                return DN_LINE_STYLE_ID;
            end
        end
    end
    
    return UP_LINE_STYLE_ID;
end

function Draw(stage, context)
    if stage == 0 then
        if not init then
            context:createPen(UP_LINE_STYLE_ID, context.SOLID, up_width, up_color);
            context:createPen(DN_LINE_STYLE_ID, context.SOLID, dn_width, dn_color);
            init = true;
        end
        
        local m1, p1;
        local m2, p2;
        local prevx;
        
        local firstBar = context:firstBar();
        local connectWithLastBar;
        local current_color = gerDirectionBefor(firstBar);
    
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        context:startEnumeration();
        while true do
            index, x, x1, x2, c1, c2 = context:nextBar();
            if index == -1 or index == nil then
                break;
            end
            if index ~= firstBar then
                connectWithLastBar = true;
            else
                connectWithLastBar = false;
            end
            
            local open_price = open[index];
            local close_price = close[index];
            if open_price < close_price then
                if current_color ~= UP_LINE_STYLE_ID and isSwitchToUp(index) then
                    drawSection(context, current_color, open_price, open[index - 1], x, x1, prevx, connectWithLastBar);
                    current_color = UP_LINE_STYLE_ID;
                    open_price = open[index - 1];
                    connectWithLastBar = false;
                end
            else
                if current_color ~= DN_LINE_STYLE_ID and isSwitchToDown(index) then
                    drawSection(context, current_color, open_price, open[index - 1], x, x1, prevx, connectWithLastBar);
                    current_color = DN_LINE_STYLE_ID;
                    open_price = open[index - 1];
                    connectWithLastBar = false;
                end
            end
            drawSection(context, current_color, open_price, close_price, x, x1, prevx, connectWithLastBar);
            prevx = x;
        end
        context:resetClipRectangle();
    end
end
end

function ReleaseInstance()
    if instance.parameters.to == 0 then
        core.host:execute("unsubscribeTradeEvents", "offers");
    end
end