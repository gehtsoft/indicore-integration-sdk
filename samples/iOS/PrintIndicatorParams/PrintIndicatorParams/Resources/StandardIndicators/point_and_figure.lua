function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);

    indicator.parameters:addGroup(resources:get("R_price_params_group"));
    indicator.parameters:addString("I", resources:get("R_instrument_name"), resources:get("R_instrument_desc"), "");
    indicator.parameters:setFlag("I", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("TF", resources:get("R_timeframe_name"), resources:get("R_timeframe_desc"), "m1");
    indicator.parameters:setFlag("TF", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", resources:get("R_pricetype_name"), resources:get("R_pricetype_desc"), true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addInteger("BS", resources:get("box_size"), resources:get("box_size_desc"), 10, 1, 100);
    indicator.parameters:addInteger("RC", resources:get("sensitivity"), resources:get("sensitivity_desc"), 3, 1, 100);
    
    indicator.parameters:addGroup(resources:get("R_range_group"));
    indicator.parameters:addDate("from", resources:get("R_date_from_name"), resources:get("R_date_from_desc"), -10);
    indicator.parameters:addDate("to", resources:get("R_date_to_name"), resources:get("R_date_to_desc"), 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);

    indicator.parameters:addGroup(resources:get("R_style_group"));
    indicator.parameters:addColor("clrMU", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_rows_up_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_rows_up_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrMD", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_rows_dn_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_rows_dn_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrRU", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_reverse_movement_up_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_reverse_movement_up_desc")), core.rgb(0, 192, 0));
    indicator.parameters:addColor("clrRD", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_reverse_movement_dn_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_reverse_movement_dn_desc")), core.rgb(192, 0, 0));

    indicator.parameters:addBoolean("G", resources:get("show_price_grid"), resources:get("g_desc"), false);
    indicator.parameters:addColor("clrG", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_price_grid_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_price_grid_desc")), core.rgb(128, 128, 128));
    indicator.parameters:addInteger("GM", resources:get("max_grid_font_size_name"), resources:get("gm_desc"), 8, 4, 32);
end

local alive, loading;
local source;
local open, high, low, close, direction, current;
local BS, RC;
local clrRU, clrRD, clrMU, clrMD, clrG, G, GM;
local format;

function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.parameters.I .. "." .. instance.parameters.TF .. "," ..
                                        instance.parameters.BS .. "," .. instance.parameters.RC .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    alive = instance.parameters.to == 0;
    loading = true;
    source = core.host:execute("getHistory", 2, instance.parameters.I, instance.parameters.TF, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    if alive then
        core.host:execute("setTimer", 1, 1);
    end
    core.host:execute("setStatus", resources:get("R_status_loading"));

    BS = instance.parameters.BS * source:pipSize();
    RC = instance.parameters.RC * BS;

    instance:initView(instance.parameters.I, source:getPrecision(), source:pipSize(), true, alive);

    open = instance:addStream("open", core.Line, name .. "." .. resources:get("R_open_price"), "open", core.rgb(0, 0, 0), 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. resources:get("R_high_price"), "high", core.rgb(0, 0, 0), 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. resources:get("R_low_price"), "low", core.rgb(0, 0, 0), 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. resources:get("R_close_price"), "close", core.rgb(0, 0, 0), 0, 0);
    direction = instance:addInternalStream(0, 0);
    current = instance:addInternalStream(0, 0);

    instance:createCandleGroup("pf", "pf", open, high, low, close, nil, "PF", false);

    open:setVisible(false);
    high:setVisible(false);
    low:setVisible(false);
    close:setVisible(false);
    G = instance.parameters.G;
    GM = instance.parameters.GM;
    clrG = instance.parameters.clrG;
    clrRU = instance.parameters.clrRU;
    clrMU = instance.parameters.clrMU;
    clrRD = instance.parameters.clrRD;
    clrMD = instance.parameters.clrMD;
    instance:ownerDrawn(true);
    format = string.format("%%.%if", source:getPrecision());
end

function Update(period, mode)
end

local lastSerial = nil;

function AsyncOperationFinished(cookie, success, message)
    if cookie == 2 then
        if success then
           local i, d;
           d = source:size() - 1;
           for i = 0, d, 1 do
               if i == d and alive then
                   lastSerial = source:serial(i);
               else
                   addSourceBar(i);
               end
           end
           core.host:execute("setStatus", "");
           loading = false;
       else
          core.host:trace("The indicator could not get the history");        
       end    
    elseif cookie == 1 then
        if not loading then
            if lastSerial ~= nil and lastSerial ~= source:serial(source:size() - 1) then
                -- add the last completed bar
                addSourceBar(source:size() - 2);
                lastSerial = source:serial(source:size() - 1);
            end
        end
    end
end

local empty = true;

function addSourceBar(period)
    local curr;
    if empty then
        -- detect initial direction by the first bar
        instance:addViewBar(source:date(period));
        curr = open:size() - 1;
        if open[period] < close[period] then
            direction[curr] = 1;
        else
            direction[curr] = -1;
        end
        local box = tobox(source.close[period]);
        current[curr] = box;
        high[curr] = box + BS;
        low[curr] = box;
        if direction[period] > 0 then
            open[curr] = low[curr];
            close[curr] = high[curr];
        else
            open[curr] = high[curr];
            close[curr] = low[curr];
        end
        empty = false;
    else
        -- update the current box
        curr = open:size() - 1;
        local dir = direction[curr];
        local box = tobox(source.close[period]);
        if dir > 0 then
            if box < high[curr] - RC - BS then
                instance:addViewBar(source:date(period));
                curr = curr + 1;
                high[curr] = high[curr - 1] - BS;
                low[curr] = box;
                direction[curr] = -1;
                open[curr] = high[curr];
                close[curr] = low[curr];
                current[curr] = box;
            else
                high[curr] = math.max(high[curr], box + BS);
                low[curr] = math.min(low[curr], box);
                open[curr] = low[curr];
                close[curr] = high[curr];
                current[curr] = box;
            end
        else
            if box > low[curr] + RC then
                instance:addViewBar(source:date(period));
                curr = curr + 1;
                low[curr] = low[curr - 1] + BS;
                high[curr] = box + BS;
                direction[curr] = 1;
                close[curr] = high[curr];
                open[curr] = low[curr];
                current[curr] = box;
            else
                high[curr] = math.max(high[curr], box + BS);
                low[curr] = math.min(low[curr], box);
                open[curr] = high[curr];
                close[curr] = low[curr];
                current[curr] = box;
            end
        end
    end
end

function tobox(price)
    return math.floor(price / BS) * BS;
end

local lastGF = nil;
local init=true;
local UP_PEN = 4;
local REVERSAV_UP_PEN = 5;
local DOWN_PEN = 6;
local REVERSAV_DOWN_PEN = 7;
local pensInitialized = false;

function Draw(stage, context)
    if stage == 0 and G then
        local gf;
        cellH = math.floor(context:priceWidth(open[0], open[0] + BS) + 0.5);
        if cellH < 1 then
            cellH = 1;
        end
        gf = cellH;
        local t = context:pointsToPixels(GM);
        if gf > t then
            gf = t;
        end
        if lastGF == nil or gf ~= lastGF then
            lastGF = gf;
            context:createFont(2, "Verdana", 0, -gf, 0);
            context:createPen(3, context.DOT, 1, clrG);
        end
        local from = tobox(context:maxPrice());
        local to = tobox(context:minPrice());
        local yfrom, yto;
        local left, right;
        left = context:left();
        right = context:right();
        local t;
        t, yfrom = context:pointOfPrice(from);
        t, yto = context:pointOfPrice(to);
        local y;
        local label;
        local p = from;
        local style = context.RIGHT + context.VCENTER + context.SINGLELINE;

        -- clip the output to the chart area
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        for y = yfrom, yto, cellH do
            context:drawLine(3, left, y, right, y);
            label = string.format(format, p);
            context:drawText(2, label, clrG, -1, left, y - cellH, right, y, style);
            p = p - BS;
        end
        context:resetClipRectangle();
    elseif stage == 2 and open:size() > 0 then
        if not pensInitialized then
            pensInitialized = true;
            context:createPen(UP_PEN,            context.SOLID, 1, clrMU);
            context:createPen(DOWN_PEN,          context.SOLID, 1, clrMD);
            
            context:createPen(REVERSAV_UP_PEN,   context.SOLID, 1, clrRU);
            context:createPen(REVERSAV_DOWN_PEN, context.SOLID, 1, clrRD);
        end

        -- check font parameters
        local cellW, cellH;

        local t, s, e;
        cellH = context:priceWidth(open[0], open[0] + BS);
        if cellH < 1 then
            cellH = 1;
        end
        t, s, e = context:positionOfBar(0);
        cellW = math.floor(e - s + 0.5);
        -- clip the output to the chart area
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        if cellW <= 8 or cellH <= 8 then
            drawUsingLines(context, cellW, cellH);
        else
            drawUsingFont(context, cellW, cellH);
        end
        context:resetClipRectangle();
    end
end

function drawUsingLines(context, cellW, cellH)
    context:startEnumeration();
    while true do
        local index, x, x1, x2 = context:nextBar();
        if index == nil then
            break;
        end

        local last = false;
        if open:isAlive() and index == open:size() - 1 then
            last = true;
        end

        local t, y, hy, ly;
        t, hy = context:pointOfPrice(high[index]);
        t, ly = context:pointOfPrice(low[index]);
        if last then
            t, y  = context:pointOfPrice(current[index]);
            if direction[index] < 0 then
                context:drawLine(DOWN_PEN,          x, hy, x,  y);
                context:drawLine(REVERSAV_DOWN_PEN, x,  y, x, ly);
            else
                context:drawLine(UP_PEN,            x, ly, x,  y);
                context:drawLine(REVERSAV_UP_PEN,   x,  y, x, hy);
            end
        else
            if direction[index] < 0 then
                context:drawLine(DOWN_PEN, x, hy, x, ly);
            else
                context:drawLine(UP_PEN,   x, ly, x, hy);
            end
        end
    end
end

function drawUsingFont(context, cellW, cellH)
    context:startEnumeration();

    while true do
        local index, x, x1, x2 = context:nextBar();
        if index == nil then
            break;
        end

        local rateStep, color, dir;
        local last = false;
        if open:isAlive() and index == open:size() - 1 then
            last = true;
        end
        if direction[index] < 0 then
            dir = -1;
        else
            dir = 1;
        end
        if high[index] - BS > low[index] then
            rateStep = -BS;
        else
            rateStep = BS;
        end

        local style = context.CENTER + context.VCENTER + context.SINGLELINE;

        local sizex, sizey = math.floor((x2 - x1) / 2) - 1, math.floor(cellH / 2) - 1;
            
        local cellH_ = math.min(sizey, sizex);
        x1 = x - cellH_;
        x2 = x + cellH_;

        local t, y;
        local pen;
        if last then
            for i = high[index] - BS, low[index], rateStep do
                t, y = context:pointOfPrice(i);
                if dir == 1 then
                    if i <= current[index] then
                        pen = UP_PEN;
                    else
                        pen = REVERSAV_UP_PEN;
                    end
                    context:drawLine(pen, x1, y - 2 * cellH_, x2 + 1, y + 1);
                    context:drawLine(pen, x1, y, x2 + 1, y - 2 * cellH_ - 1);
                else
                    if i > current[index] then
                        pen = DOWN_PEN;
                    else
                        pen = REVERSAV_DOWN_PEN;
                    end
                    context:drawEllipse(pen, -1, x1, y - 2 * cellH_, x2 + 1, y + 1);
                end
            end
        else
            for i = high[index] - BS, low[index], rateStep do
                t, y = context:pointOfPrice(i);
                if dir == 1 then
                    context:drawLine(UP_PEN, x1, y - 2 * cellH_, x2 + 1, y + 1);
                    context:drawLine(UP_PEN, x1, y, x2 + 1, y - 2 * cellH_ - 1);
                else
                    context:drawEllipse(DOWN_PEN, -1, x1, y - 2 * cellH_, x2 + 1, y + 1);
                end
            end
        end
    end
end
