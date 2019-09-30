-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name(resources:get("param_Name"));
    indicator:description(resources:get("param_Description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("KPeriod", resources:get("param_KPeriod"),resources:get("param_KPeriod_desc"), 5);
    indicator.parameters:addInteger("DPeriod", resources:get("param_DPeriod"),resources:get("param_DPeriod_desc"), 3);
    indicator.parameters:addInteger("Slowing", resources:get("param_Slowing"),resources:get("param_Slowing_desc"), 3);
    indicator.parameters:addInteger("RSIPeriod", resources:get("param_RSIPeriod"), resources:get("param_RSIPeriod"), 14);
    indicator.parameters:addInteger("CCIPeriod", resources:get("param_CCIPeriod"), resources:get("param_CCIPeriod_desc"), 14);
    indicator.parameters:addInteger("FastEMA", resources:get("param_FastEMA"), resources:get("param_FastEMA_desc"), 12);
    indicator.parameters:addInteger("SlowEMA", resources:get("param_SlowEMA"), resources:get("param_SlowEMA_desc"), 26);
    indicator.parameters:addInteger("SignalSMA", resources:get("param_SignalSMA"), resources:get("param_SignalSMA_desc"), 9);
    indicator.parameters:addInteger("MAPeriod1", resources:get("param_MAPeriod1"), resources:get("param_MAPeriod1_desc"), 5);
    indicator.parameters:addInteger("MAPeriod2", resources:get("param_MAPeriod2"), resources:get("param_MAPeriod2_desc"), 8);
    indicator.parameters:addBoolean("Debug", resources:get("param_Debug"), "", false);
    indicator.parameters:addColor("UP_color", resources:get("param_UP_color"), resources:get("param_UP_color_desc"), core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN_color", resources:get("param_DOWN_color"), resources:get("param_DOWN_color_desc"), core.rgb(255, 0, 0));
    indicator.parameters:addColor("EQ_color", resources:get("param_EQ_color"), resources:get("param_EQ_color_desc"), core.rgb(128, 128, 128));
    indicator.parameters:addColor("Header_color", resources:get("param_Header_color"), resources:get("param_Header_color_desc"), core.rgb(255, 128, 64));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local KPeriod;
local DPeriod;
local Slowing;
local RSIPeriod;
local CCIPeriod;
local FastEMA;
local SlowEMA;
local SignalSMA;
local MAPeriod1;
local MAPeriod2;
local Debug;
local LabelID;
local first;
local source = nil;

-- Streams block
local S1 = nil;
local font1, font2;

local TF1, TF5, TF15, TF30, TF60, TF240;
local iStoch1, iStoch5, iStoch15, iStoch30, iStoch60, iStoch240;
local iRSI1, iRSI5, iRSI15, iRSI30, iRSI60, iRSI240;
local iCCI1, iCCI5, iCCI15, iCCI30, iCCI60, iCCI240;
local iMACD1, iMACD5, iMACD15, iMACD30, iMACD60, iMACD240;
local iEMA1_1, iEMA1_5, iEMA1_15, iEMA1_30, iEMA1_60, iEMA1_240; 
local iEMA2_1, iEMA2_5, iEMA2_15, iEMA2_30, iEMA2_60, iEMA2_240;

local fileName = "";
local File;

-- Routine
function Prepare(nameOnly)
    KPeriod = instance.parameters.KPeriod;
    DPeriod = instance.parameters.DPeriod;
    Slowing = instance.parameters.Slowing;
    RSIPeriod = instance.parameters.RSIPeriod;
    CCIPeriod = instance.parameters.CCIPeriod;
    FastEMA = instance.parameters.FastEMA;
    SlowEMA = instance.parameters.SlowEMA;
    SignalSMA = instance.parameters.SignalSMA;
    MAPeriod1 = instance.parameters.MAPeriod1;
    MAPeriod2 = instance.parameters.MAPeriod2;
    Debug = instance.parameters.Debug;
    
    TF1 = nil;
    source = instance.source;
    first = source:first();
    
    
    local cur = source:instrument();
    local pos = string.find(cur, "/");
    if pos ~= nil then
        cur = string.sub(cur, 0, pos-1)..string.sub(cur, pos+1);
    end

    if instance.parameters.Debug == true then    
       fileName = tostring("c:\\Marketscope Logs\\" .. profile:id().."_"..tostring(cur)..".txt");
       core.host:trace("fileName: " .. fileName);
       os.execute('MKDIR "'.."c://Marketscope Logs//"..'"');
    end
 
    printToFile("----------------------------------------------------");    
    printToFile("first: " .. tostring(first));
    printToFile("instrument: " .. tostring(source:instrument()));
    printToFile("isBid: " .. tostring(source:isBid()));
    --printToFile("date: " .. tostring(source:date(source:first())));
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(KPeriod) .. ", " .. tostring(DPeriod) .. ", " .. tostring(Slowing) .. ", " .. tostring(RSIPeriod) .. ", " .. tostring(CCIPeriod) .. ", " .. tostring(FastEMA) .. ", " .. tostring(SlowEMA) .. ", " .. tostring(SignalSMA) .. ", " .. tostring(MAPeriod1) .. ", " .. tostring(MAPeriod2) .. ", " .. tostring(Debug) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        --S1 = instance:addStream("S1", core.Line, name, "S1", instance.parameters.S1_color, first);
    end

    LabelID = 0;
    font1 = core.host:execute("createFont", "Arial", 12, false, false);
    font2 = core.host:execute("createFont", "Wingdings", 20, false, true);

    DrawHeader();
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
    if not source:hasData(period) or period < source:size()-1 or period < first then
        return;
    end
    
    if TF1 == nil then
        printToFile("calculating...");
        --create all timeframe sources
        TF1 = core.host:execute("getHistory", 1, source:instrument(), "m1", source:date(source:first()), 0, source:isBid());
        TF5 = core.host:execute("getHistory", 2, source:instrument(), "m5", source:date(source:first()), 0, source:isBid());
        TF15 = core.host:execute("getHistory", 3, source:instrument(), "m15", source:date(source:first()), 0, source:isBid());
        TF30 = core.host:execute("getHistory", 4, source:instrument(), "m30", source:date(NOW)-10, 0, source:isBid());
        TF60 = core.host:execute("getHistory", 5, source:instrument(), "H1", source:date(NOW)-10, 0, source:isBid());
        TF240 = core.host:execute("getHistory", 6, source:instrument(), "H4", source:date(NOW)-10, 0, source:isBid());

        --Create Stoch indicators
        iStoch1 = core.indicators:create("STOCHASTIC", TF1, KPeriod, Slowing, DPeriod);
        iStoch5 = core.indicators:create("STOCHASTIC", TF5, KPeriod, Slowing, DPeriod);
        iStoch15 = core.indicators:create("STOCHASTIC", TF15, KPeriod, Slowing, DPeriod);
        iStoch30 = core.indicators:create("STOCHASTIC", TF30, KPeriod, Slowing, DPeriod);
        iStoch60 = core.indicators:create("STOCHASTIC", TF60, KPeriod, Slowing, DPeriod);
        iStoch240 = core.indicators:create("STOCHASTIC", TF240, KPeriod, Slowing, DPeriod);

        iRSI1 = core.indicators:create("RSI", TF1.close, RSIPeriod);
        iRSI5 = core.indicators:create("RSI", TF5.close, RSIPeriod);
        iRSI15 = core.indicators:create("RSI", TF15.close, RSIPeriod);
        iRSI30 = core.indicators:create("RSI", TF30.close, RSIPeriod);
        iRSI60 = core.indicators:create("RSI", TF60.close, RSIPeriod);
        iRSI240 = core.indicators:create("RSI", TF240.close, RSIPeriod);

        iCCI1 = core.indicators:create("CCI", TF1, CCIPeriod);
        iCCI5 = core.indicators:create("CCI", TF5, CCIPeriod);
        iCCI15 = core.indicators:create("CCI", TF15, CCIPeriod);
        iCCI30 = core.indicators:create("CCI", TF30, CCIPeriod);
        iCCI60 = core.indicators:create("CCI", TF60, CCIPeriod);
        iCCI240 = core.indicators:create("CCI", TF240, CCIPeriod);

        iMACD1 = core.indicators:create("MACD", TF1.close, FastEMA, SlowEMA, SignalSMA);
        iMACD5 = core.indicators:create("MACD", TF5.close, FastEMA, SlowEMA, SignalSMA);
        iMACD15 = core.indicators:create("MACD", TF15.close, FastEMA, SlowEMA, SignalSMA);
        iMACD30 = core.indicators:create("MACD", TF30.close, FastEMA, SlowEMA, SignalSMA);
        iMACD60 = core.indicators:create("MACD", TF60.close, FastEMA, SlowEMA, SignalSMA);
        iMACD240 = core.indicators:create("MACD", TF240.close, FastEMA, SlowEMA, SignalSMA);

        iEMA1_1 = core.indicators:create("EMA", TF1.close, MAPeriod1);
        iEMA1_5 = core.indicators:create("EMA", TF5.close, MAPeriod1);
        iEMA1_15 = core.indicators:create("EMA", TF15.close, MAPeriod1);
        iEMA1_30 = core.indicators:create("EMA", TF30.close, MAPeriod1);
        iEMA1_60 = core.indicators:create("EMA", TF60.close, MAPeriod1);
        iEMA1_240 = core.indicators:create("EMA", TF240.close, MAPeriod1);

        iEMA2_1 = core.indicators:create("EMA", TF1.close, MAPeriod2);
        iEMA2_5 = core.indicators:create("EMA", TF5.close, MAPeriod2);
        iEMA2_15 = core.indicators:create("EMA", TF15.close, MAPeriod2);
        iEMA2_30 = core.indicators:create("EMA", TF30.close, MAPeriod2);
        iEMA2_60 = core.indicators:create("EMA", TF60.close, MAPeriod2);
        iEMA2_240 = core.indicators:create("EMA", TF240.close, MAPeriod2);
    else
        
        iStoch1:update(core.UpdateLast);
        iStoch5:update(core.UpdateLast);
        iStoch15:update(core.UpdateLast);
        iStoch30:update(core.UpdateLast);
        iStoch60:update(core.UpdateLast);
        iStoch240:update(core.UpdateLast);

        iRSI1:update(core.UpdateLast);
        iRSI5:update(core.UpdateLast);
        iRSI15:update(core.UpdateLast);
        iRSI30:update(core.UpdateLast);
        iRSI60:update(core.UpdateLast);
        iRSI240:update(core.UpdateLast);

        iCCI1:update(core.UpdateLast);
        iCCI5:update(core.UpdateLast);
        iCCI15:update(core.UpdateLast);
        iCCI30:update(core.UpdateLast);
        iCCI60:update(core.UpdateLast);
        iCCI240:update(core.UpdateLast);

        iMACD1:update(core.UpdateLast);
        iMACD5:update(core.UpdateLast);
        iMACD15:update(core.UpdateLast);
        iMACD30:update(core.UpdateLast);
        iMACD60:update(core.UpdateLast);
        iMACD240:update(core.UpdateLast);

        iEMA1_1:update(core.UpdateLast);
        iEMA1_5:update(core.UpdateLast);
        iEMA1_15:update(core.UpdateLast);
        iEMA1_30:update(core.UpdateLast);
        iEMA1_60:update(core.UpdateLast);
        iEMA1_240:update(core.UpdateLast);

        iEMA2_1:update(core.UpdateLast);
        iEMA2_5:update(core.UpdateLast);
        iEMA2_15:update(core.UpdateLast);
        iEMA2_30:update(core.UpdateLast);
        iEMA2_60:update(core.UpdateLast);
        iEMA2_240:update(core.UpdateLast);

        local StochMain1 = iStoch1.K;
        local StochSignal1 = iStoch1.D;
        local StochMain5 = iStoch5.K;
        local StochSignal5 = iStoch5.D;
        local StochMain15 = iStoch15.K;
        local StochSignal15 = iStoch15.D;
        local StochMain30 = iStoch30.K;
        local StochSignal30 = iStoch30.D;
        local StochMain60 = iStoch60.K;
        local StochSignal60 = iStoch60.D;
        local StochMain240 = iStoch240.K;
        local StochSignal240 = iStoch240.D;

        local RSI1 = iRSI1.RSI;
        local RSI5 = iRSI5.RSI;
        local RSI15 = iRSI15.RSI;
        local RSI30 = iRSI30.RSI;
        local RSI60 = iRSI60.RSI;
        local RSI240 = iRSI240.RSI;

        local CCI1 = iCCI1.CCI;
        local CCI5 = iCCI5.CCI;
        local CCI15 = iCCI15.CCI;
        local CCI30 = iCCI30.CCI;
        local CCI60 = iCCI60.CCI;
        local CCI240 = iCCI240.CCI;

        local MACDHist1 = iMACD1.HISTOGRAM;
        local MACDSignal1 = iMACD1.SIGNAL;
        local MACDHist5 = iMACD5.HISTOGRAM;
        local MACDSignal5 = iMACD5.SIGNAL;
        local MACDHist15 = iMACD15.HISTOGRAM;
        local MACDSignal15 = iMACD15.SIGNAL;
        local MACDHist30 = iMACD30.HISTOGRAM;
        local MACDSignal30 = iMACD30.SIGNAL;
        local MACDHist60 = iMACD60.HISTOGRAM;
        local MACDSignal60 = iMACD60.SIGNAL;
        local MACDHist240 = iMACD240.HISTOGRAM;
        local MACDSignal240 = iMACD240.SIGNAL;

        local EMA1_1 = iEMA1_1.EMA;
        local EMA1_5 = iEMA1_5.EMA;
        local EMA1_15 = iEMA1_15.EMA;
        local EMA1_30 = iEMA1_30.EMA;
        local EMA1_60 = iEMA1_60.EMA;
        local EMA1_240 = iEMA1_240.EMA;

        local EMA2_1 = iEMA2_1.EMA;
        local EMA2_5 = iEMA2_5.EMA;
        local EMA2_15 = iEMA2_15.EMA;
        local EMA2_30 = iEMA2_30.EMA;
        local EMA2_60 = iEMA2_60.EMA;
        local EMA2_240 = iEMA2_240.EMA;

        local top = 80;
        local left = -240;
        local hstep = 40;
        local vstep = 40;
        local col, row;

        ClearArrows();

        if period >= first and source:hasData(period) then
            LabelID = 1;
            --check stoch m1 signals
            row = 0;
            col = 0;
            if StochMain1:size() > 0 and StochSignal1:size() > 0 then
                local stochmain1 = StochMain1[StochMain1:size()-1];
                local stochsignal1 = StochSignal1[StochSignal1:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1M Stoch Main = "..tostring(stochmain1)..",   Stoch Signal = "..tostring(stochsignal1));
                if stochsignal1 < stochmain1 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif stochsignal1 > stochmain1 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check stoch m5 signals
            row = 0;
            col = 1;
            LabelID = LabelID+1;
            if StochMain5:size() > 0 and StochSignal5:size() > 0 then
                local stochmain5 = StochMain5[StochMain5:size()-1];
                local stochsignal5 = StochSignal5[StochSignal5:size()-1];
                printToFile(core.formatDate(source:date(period)).."   5M Stoch Main = "..tostring(stochmain5)..",   Stoch Signal = "..tostring(stochsignal5));
                if stochsignal5 < stochmain5 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif stochsignal5 > stochmain5 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check stoch m15 signals
            row = 0;
            col = 2;
            LabelID = LabelID+1;
            if StochMain15:size() > 0 and StochSignal15:size() > 0 then
                local stochmain15 = StochMain15[StochMain15:size()-1];
                local stochsignal15 = StochSignal15[StochSignal15:size()-1];
                printToFile(core.formatDate(source:date(period)).."   15M Stoch Main = "..tostring(stochmain15)..",   Stoch Signal = "..tostring(stochsignal15));
                if stochsignal15 < stochmain15 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif stochsignal15 > stochmain15 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check stoch m30 signals
            row = 0;
            col = 3;
            LabelID = LabelID+1;
            if StochMain30:size() > 0 and StochSignal30:size() > 0 then
                local stochmain30 = StochMain30[StochMain30:size()-1];
                local stochsignal30 = StochSignal30[StochSignal30:size()-1];
                printToFile(core.formatDate(source:date(period)).."   30M Stoch Main = "..tostring(stochmain30)..",   Stoch Signal = "..tostring(stochsignal30));
                if stochsignal30 < stochmain30 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif stochsignal30 > stochmain30 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check stoch H1 signals
            row = 0;
            col = 4;
            LabelID = LabelID+1;
            if StochMain60:size() > 0 and StochSignal60:size() > 0 then
                local stochmain60 = StochMain60[StochMain60:size()-1];
                local stochsignal60 = StochSignal60[StochSignal60:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1H Stoch Main = "..tostring(stochmain60)..",   Stoch Signal = "..tostring(stochsignal60));
                if stochsignal60 < stochmain60 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif stochsignal60 > stochmain60 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check stoch H4 signals
            row = 0;
            col = 5;
            LabelID = LabelID+1;
            if StochMain240:size() > 0 and StochSignal240:size() > 0 then
                local stochmain240 = StochMain240[StochMain240:size()-1];
                local stochsignal240 = StochSignal240[StochSignal240:size()-1];
                printToFile(core.formatDate(source:date(period)).."   4H Stoch Main = "..tostring(stochmain240)..",   Stoch Signal = "..tostring(stochsignal240));
                if stochsignal240 < stochmain240 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif stochsignal240 > stochmain240 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end

    ----------------------------------------------------------------------------------------
            --check RSI m1 signals
            row = 1;
            col = 0;
            LabelID = LabelID+1;
            if RSI1:size() > 0 then
                local rsi1 = RSI1[RSI1:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1M RSI = "..tostring(rsi1));
                if rsi1 > 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif rsi1 < 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check RSI m5 signals
            row = 1;
            col = 1;
            LabelID = LabelID+1;
            if RSI5:size() > 0 then
                local rsi5 = RSI5[RSI5:size()-1];
                printToFile(core.formatDate(source:date(period)).."   5M RSI = "..tostring(rsi5));
                if rsi5 > 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif rsi5 < 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check RSI m15 signals
            row = 1;
            col = 2;
            LabelID = LabelID+1;
            if RSI15:size() > 0 then
                local rsi15 = RSI15[RSI15:size()-1];
                printToFile(core.formatDate(source:date(period)).."   15M RSI = "..tostring(rsi15));
                if rsi15 > 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif rsi15 < 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check RSI m30 signals
            row = 1;
            col = 3;
            LabelID = LabelID+1;
            if RSI30:size() > 0 then
                local rsi30 = RSI30[RSI30:size()-1];
                printToFile(core.formatDate(source:date(period)).."   30M RSI = "..tostring(rsi30));
                if rsi30 > 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif rsi30 < 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check RSI H1 signals
            row = 1;
            col = 4;
            LabelID = LabelID+1;
            if RSI60:size() > 0 then
                local rsi60 = RSI60[RSI60:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1H RSI = "..tostring(rsi60));
                if rsi60 > 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif rsi60 < 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check RSI H4 signals
            row = 1;
            col = 5;
            LabelID = LabelID+1;
            if RSI240:size() > 0 then
                local rsi240 = RSI240[RSI240:size()-1];
                printToFile(core.formatDate(source:date(period)).."   4H RSI = "..tostring(rsi240));
                if rsi240 > 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif rsi240 < 50 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
    -----------------------------------------------------------------------------
            --check CCI m1 signals
            row = 2;
            col = 0;
            LabelID = LabelID+1;
            if CCI1:size() > 0 then
                local cci1 = CCI1[CCI1:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1M CCI = "..tostring(cci1));
                if cci1 > 100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif cci1 < -100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check CCI m5 signals
            row = 2;
            col = 1;
            LabelID = LabelID+1;
            if CCI5:size() > 0 then
                local cci5 = CCI5[CCI5:size()-1];
                printToFile(core.formatDate(source:date(period)).."   5M CCI = "..tostring(cci5));
                if cci5 > 100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif cci5 < -100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check CCI m15 signals
            row = 2;
            col = 2;
            LabelID = LabelID+1;
            if CCI15:size() > 0 then
                local cci15 = CCI15[CCI15:size()-1];
                printToFile(core.formatDate(source:date(period)).."   15M CCI = "..tostring(cci15));
                if cci15 > 100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif cci15 < -100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check CCI m30 signals
            row = 2;
            col = 3;
            LabelID = LabelID+1;
            if CCI30:size() > 0 then
                local cci30 = CCI30[CCI30:size()-1];
                printToFile(core.formatDate(source:date(period)).."   30M CCI = "..tostring(cci30));
                if cci30 > 100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif cci30 < -100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check CCI H1 signals
            row = 2;
            col = 4;
            LabelID = LabelID+1;
            if CCI60:size() > 0 then
                local cci60 = CCI60[CCI60:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1H CCI = "..tostring(cci60));
                if cci60 > 100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif cci60 < -100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check CCI H4 signals
            row = 2;
            col = 5;
            LabelID = LabelID+1;
            if CCI240:size() > 0 then
                local cci240 = CCI240[CCI240:size()-1];
                printToFile(core.formatDate(source:date(period)).."   4H CCI = "..tostring(cci240));
                if cci240 > 100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif cci240 < -100 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
    ------------------------------------------------------------------------------
            --check MACD m1 signals
            row = 3;
            col = 0;
            LabelID = LabelID+1;
            if MACDHist1:size() > 0 and MACDSignal1:size() > 0 then
                local macdhist1 = MACDHist1[MACDHist1:size()-1];
                local macdsignal1 = MACDSignal1[MACDSignal1:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1M MACD Histogram = "..tostring(macdhist1)..",   MACD Signal = "..tostring(macdsignal1));
                if (macdhist1 > 0 and macdsignal1 > 0 and macdsignal1 < macdhist1) or (macdhist1 < 0 and macdsignal1 < macdhist1) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif (macdhist1 < 0 and macdsignal1 < 0 and macdsignal1 > macdhist1) or (macdhist1 > 0 and macdsignal1 > macdhist1) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check MACD m5 signals
            row = 3;
            col = 1;
            LabelID = LabelID+1;
            if MACDHist5:size() > 0 and MACDSignal5:size() > 0 then
                local macdhist5 = MACDHist5[MACDHist5:size()-1];
                local macdsignal5 = MACDSignal5[MACDSignal5:size()-1];
                printToFile(core.formatDate(source:date(period)).."   5M MACD Histogram = "..tostring(macdhist5)..",   MACD Signal = "..tostring(macdsignal5));
                if (macdhist5 > 0 and macdsignal5 > 0 and macdsignal5 < macdhist5) or (macdhist5 < 0 and macdsignal5 < macdhist5) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif (macdhist5 < 0 and macdsignal5 < 0 and macdsignal5 > macdhist5) or (macdhist5 > 0 and macdsignal5 > macdhist5) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check MACD m15 signals
            row = 3;
            col = 2;
            LabelID = LabelID+1;
            if MACDHist15:size() > 0 and MACDSignal15:size() > 0 then
                local macdhist15 = MACDHist15[MACDHist15:size()-1];
                local macdsignal15 = MACDSignal15[MACDSignal15:size()-1];
                printToFile(core.formatDate(source:date(period)).."   15M MACD Histogram = "..tostring(macdhist15)..",   MACD Signal = "..tostring(macdsignal15));
                if (macdhist15 > 0 and macdsignal15 > 0 and macdsignal15 < macdhist15) or (macdhist15 < 0 and macdsignal15 < macdhist15) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif (macdhist15 < 0 and macdsignal15 < 0 and macdsignal15 > macdhist15) or (macdhist15 > 0 and macdsignal15 > macdhist15) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check MACD m30 signals
            row = 3;
            col = 3;
            LabelID = LabelID+1;
            if MACDHist30:size() > 0 and MACDSignal30:size() > 0 then
                local macdhist30 = MACDHist30[MACDHist30:size()-1];
                local macdsignal30 = MACDSignal30[MACDSignal30:size()-1];
                printToFile(core.formatDate(source:date(period)).."   30M MACD Histogram = "..tostring(macdhist30)..",   MACD Signal = "..tostring(macdsignal30));
                if (macdhist30 > 0 and macdsignal30 > 0 and macdsignal30 < macdhist30) or (macdhist30 < 0 and macdsignal30 < macdhist30) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif (macdhist30 < 0 and macdsignal30 < 0 and macdsignal30 > macdhist30) or (macdhist30 > 0 and macdsignal30 > macdhist30) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check MACD H1 signals
            row = 3;
            col = 4;
            LabelID = LabelID+1;
            if MACDHist60:size() > 0 and MACDSignal60:size() > 0 then
                local macdhist60 = MACDHist60[MACDHist60:size()-1];
                local macdsignal60 = MACDSignal60[MACDSignal60:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1H MACD Histogram = "..tostring(macdhist60)..",   MACD Signal = "..tostring(macdsignal60));
                if (macdhist60 > 0 and macdsignal60 > 0 and macdsignal60 < macdhist60) or (macdhist60 < 0 and macdsignal60 < macdhist60) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif (macdhist60 < 0 and macdsignal60 < 0 and macdsignal60 > macdhist60) or (macdhist60 > 0 and macdsignal60 > macdhist60) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check MACD H4 signals
            row = 3;
            col = 5;
            LabelID = LabelID+1;
            if MACDHist240:size() > 0 and MACDSignal240:size() > 0 then
                local macdhist240 = MACDHist240[MACDHist240:size()-1];
                local macdsignal240 = MACDSignal240[MACDSignal240:size()-1];
                printToFile(core.formatDate(source:date(period)).."   4H MACD Histogram = "..tostring(macdhist240)..",   MACD Signal = "..tostring(macdsignal240));
                if (macdhist240 > 0 and macdsignal240 > 0 and macdsignal240 < macdhist240) or (macdhist240 < 0 and macdsignal240 < macdhist240) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif (macdhist240 < 0 and macdsignal240 < 0 and macdsignal240 > macdhist240) or (macdhist240 > 0 and macdsignal240 > macdhist240) then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
    ----------------------------------------------------------------------------------------------------------
            --check EMA m1 signals
            row = 4;
            col = 0;
            LabelID = LabelID+1;
            if EMA1_1:size() > 0 and EMA2_1:size() > 0 then
                local ema1_1 = EMA1_1[EMA1_1:size()-1];
                local ema2_1 = EMA2_1[EMA2_1:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1M EMA1 = "..tostring(ema1_1)..",   EMA2 = "..tostring(ema2_1));
                if ema1_1 > ema2_1 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif ema1_1 < ema2_1 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check EMA m5 signals
            row = 4;
            col = 1;
            LabelID = LabelID+1;
            if EMA1_5:size() > 0 and EMA2_5:size() > 0 then
                local ema1_5 = EMA1_5[EMA1_5:size()-1];
                local ema2_5 = EMA2_5[EMA2_5:size()-1];
                printToFile(core.formatDate(source:date(period)).."   5M EMA1 = "..tostring(ema1_5)..",   EMA2 = "..tostring(ema2_5));
                if ema1_5 > ema2_5 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif ema1_5 < ema2_5 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check EMA m15 signals
            row = 4;
            col = 2;
            LabelID = LabelID+1;
            if EMA1_15:size() > 0 and EMA2_15:size() > 0 then
                local ema1_15 = EMA1_15[EMA1_15:size()-1];
                local ema2_15 = EMA2_15[EMA2_15:size()-1];
                printToFile(core.formatDate(source:date(period)).."   15M EMA1 = "..tostring(ema1_15)..",   EMA2 = "..tostring(ema2_15));
                if ema1_15 > ema2_15 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif ema1_15 < ema2_15 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check EMA m30 signals
            row = 4;
            col = 3;
            LabelID = LabelID+1;
            if EMA1_30:size() > 0 and EMA2_30:size() > 0 then
                local ema1_30 = EMA1_30[EMA1_30:size()-1];
                local ema2_30 = EMA2_30[EMA2_30:size()-1];
                printToFile(core.formatDate(source:date(period)).."   30M EMA1 = "..tostring(ema1_30)..",   EMA2 = "..tostring(ema2_30));
                if ema1_30 > ema2_30 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif ema1_30 < ema2_30 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check EMA H1 signals
            row = 4;
            col = 4;
            LabelID = LabelID+1;
            if EMA1_60:size() > 0 and EMA2_60:size() > 0 then
                local ema1_60 = EMA1_60[EMA1_60:size()-1];
                local ema2_60 = EMA2_60[EMA2_60:size()-1];
                printToFile(core.formatDate(source:date(period)).."   1H EMA1 = "..tostring(ema1_60)..",   EMA2 = "..tostring(ema2_60));
                if ema1_60 > ema2_60 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif ema1_60 < ema2_60 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
            --check EMA H4 signals
            row = 4;
            col = 5;
            LabelID = LabelID+1;
            if EMA1_240:size() > 0 and EMA2_240:size() > 0 then
                local ema1_240 = EMA1_240[EMA1_240:size()-1];
                local ema2_240 = EMA2_240[EMA2_240:size()-1];
                printToFile(core.formatDate(source:date(period)).."   4H EMA1 = "..tostring(ema1_240)..",   EMA2 = "..tostring(ema2_240));
                if ema1_240 > ema2_240 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "UP");
                elseif ema1_240 < ema2_240 then
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "DOWN");
                else
                    DrawArrow(LabelID, left+col*hstep, top+row*vstep, "EQUAL");
                end
            end
        end
    end
end

function DrawHeader()
    local top = 50;
    local left = -240;
    local hstep = 40;
    local vstep = 40;
    local color = instance.parameters.Header_color;

    --Draw title
    core.host:execute("drawLabel1", 100, -150, core.CR_RIGHT, top-30, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "*** FXCM 24 Hour Trend Locator***");

    --Draw column header
    core.host:execute("drawLabel1", 101, left+0*hstep, core.CR_RIGHT, top, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "1M");
    core.host:execute("drawLabel1", 102, left+1*hstep, core.CR_RIGHT, top, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "5M");
    core.host:execute("drawLabel1", 103, left+2*hstep, core.CR_RIGHT, top, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "15M");
    core.host:execute("drawLabel1", 104, left+3*hstep, core.CR_RIGHT, top, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "30M");
    core.host:execute("drawLabel1", 105, left+4*hstep, core.CR_RIGHT, top, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "1H");
    core.host:execute("drawLabel1", 106, left+5*hstep, core.CR_RIGHT, top, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "4H");

    --Draw row header
    core.host:execute("drawLabel1", 107, left-40, core.CR_RIGHT, top+30+0*vstep, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "Stoch");
    core.host:execute("drawLabel1", 108, left-40, core.CR_RIGHT, top+30+1*vstep, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "RSI");
    core.host:execute("drawLabel1", 109, left-40, core.CR_RIGHT, top+30+2*vstep, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "CCI");
    core.host:execute("drawLabel1", 110, left-40, core.CR_RIGHT, top+30+3*vstep, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "MACD");
    core.host:execute("drawLabel1", 111, left-40, core.CR_RIGHT, top+30+4*vstep, core.CR_TOP, core.H_Center, core.V_Center, font1, color, "EMA");

end

--Delete all arrows first
function ClearArrows()
    for i=1, LabelID do
        core.host:execute("removeLabel", i);
    end
end

--Draw an arrow
function DrawArrow(id, x, y, direction)
    local char;
    if direction == "UP" then
        char = "\233";
    elseif direction == "DOWN" then
        char = "\234";
    else
        char = "\232";
    end

    local color;
    if direction == "UP" then
        color = instance.parameters.UP_color;
    elseif direction == "DOWN" then
        color = instance.parameters.DOWN_color;
    else
        color = instance.parameters.EQ_color;
    end
    core.host:execute("drawLabel1", id, x, core.CR_RIGHT, y, core.CR_TOP, core.H_Center, core.V_Center, font2, color, char);
end

function printToFile(message)
    if instance.parameters.Debug == true then
        --try
            File = io.open(fileName, "a");
            File:write(message.."\n");
            File:flush();
            File:close();
            
        --catch err do
        --    core.host:trace("An error occured: "..err);
        --end
    end
    core.host:trace(message);     
end

function AsyncOperationFinished(cookie, success, message, message1, message2)

end


function ReleaseInstance()
   core.host:execute("deleteFont", font1);
   core.host:execute("deleteFont", font2);
end

