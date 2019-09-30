--+------------------------------------------------------------------+
--|                                                         OBOS.lua |
--|                               Copyright © 2012, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", resources:get("number_of_periods_name"), resources:get("number_of_periods_description"), 9);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", resources:get("UP_Color_name"), resources:get("UP_Color_description"), core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", resources:get("DN_Color_name"), resources:get("DN_Color_description"), core.rgb(255, 0, 0));
    indicator.parameters:addColor("OB_color", resources:get("OB_Color_name"), resources:get("OB_Color_description"), core.rgb(0, 0, 255));
end

local PERIOD;

local first;
local source = nil;

local open,low, high, close;
local MA = {};
local BUFFER = {};
local BUFFER3, BUFFER4;

local UP, DOWN;
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);

    BUFFER[1] = instance:addInternalStream(source:first(), 0);
    MA[1] = core.indicators:create("EMA", BUFFER[1], PERIOD);
    BUFFER[5] = instance:addInternalStream(MA[1].DATA:first() + PERIOD, 0);
    
    MA[2] = core.indicators:create("EMA", BUFFER[5], PERIOD);
    BUFFER[6] = instance:addInternalStream(MA[2].DATA:first(), 0);
    
    MA[3] = core.indicators:create("EMA", BUFFER[6], PERIOD);
    
    UP = instance:addInternalStream( MA[3].DATA:first(), 0);
    MA[4] = core.indicators:create("EMA", UP, PERIOD);

    if (not (nameOnly)) then
        open  = instance:addStream("open",  core.Line, name, "open",  core.rgb(128, 128, 128),  MA[4].DATA:first());
        high  = instance:addStream("high",  core.Line, name, "high",  core.rgb(128, 128, 128),  MA[4].DATA:first());
        low   = instance:addStream("low",   core.Line, name, "low",   core.rgb(128, 128, 128),  MA[4].DATA:first());
        close = instance:addStream("close", core.Line, name, "close", core.rgb(128, 128, 128),  MA[4].DATA:first());
        instance:createCandleGroup("OBOS", "", open, high, low, close);
    end
end

-- Indicator calculation routine
function Update(period,mode)
    if period < first or not source:hasData(period) then
        return;        
    end
    
    BUFFER[1][period] = (source.high[period] + source.low[period] + source.close[period] * 2) / 4;
    
    MA[1]:update(mode);
    
    if period < MA[1].DATA:first() then
        return;
    end
    
    BUFFER3 = MA[1].DATA[period];
    
    if period < MA[1].DATA:first() + PERIOD then
        return;
    end

    BUFFER4 = mathex.stdev(BUFFER[1], period - PERIOD, period);

    BUFFER[5][period] = (BUFFER[1][period] - BUFFER3) * 100 / BUFFER4;

    MA[2]:update(mode);
    if period < MA[2].DATA:first() then
        return;
    end
    
    BUFFER[6][period] = MA[2].DATA[period];

    MA[3]:update(mode);
    if period < MA[3].DATA:first() then
        return;
    end

    UP[period] = MA[3].DATA[period];

    MA[4]:update(mode);
    if period < MA[4].DATA:first() then
        return;
    end

    DOWN = MA[4].DATA[period];

    if UP[period] < DOWN then
        close[period] = UP[period];
        open[period]  = DOWN;
    else
        open[period] = DOWN;
        close[period]  = UP[period];
    end

    high[period]  = math.max(open[period],close[period]);
    low[period] = math.min(open[period],close[period]);
    
    if open[period - 1] < open[period] and close[period-1] < close[period ] then
        open:setColor(period, instance.parameters.UP_color);
    elseif open[period - 1] > open[period] and close[period-1] > close[period ] then
         open:setColor(period, instance.parameters.DN_color);	
    else
         open:setColor(period, instance.parameters.OB_color);	
    end
end
