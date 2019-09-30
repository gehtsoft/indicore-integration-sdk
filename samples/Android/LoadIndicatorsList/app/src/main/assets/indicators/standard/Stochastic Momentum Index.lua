function Init()
    indicator:name(resources:get("param_Name"));
    indicator:description(resources:get("param_Description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup(resources:get("param_CalculationGroup"));
    indicator.parameters:addInteger("Period_Q", resources:get("param_Period_Q"), "", 2);
    indicator.parameters:addInteger("Period_R", resources:get("param_Period_R"), "", 8);
    indicator.parameters:addInteger("Period_S", resources:get("param_Period_S"), "", 5);
    indicator.parameters:addInteger("Period_Signal", resources:get("param_Period_Signal"), "", 5);

    indicator.parameters:addGroup(resources:get("param_StyleGroup"));
    indicator.parameters:addColor("DATAclr", resources:get("param_DATAclr"), "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("SIGNALclr", resources:get("param_SIGNALclr"), "", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period_Q;
local Period_R;
local Period_S;
local Period_Signal;
local HQ;
local SM;
local HQ_MA_R;
local HQ_MA_S;
local SM_MA_R;
local SM_MA_S;
local sig;

local SignalBuff;
local DataBuff;

function Prepare()
    source = instance.source;
    Period_Q=instance.parameters.Period_Q;
    Period_R=instance.parameters.Period_R;
    Period_S=instance.parameters.Period_S;
    Period_Signal=instance.parameters.Period_Signal;
    first = source:first();
    HQ = instance:addInternalStream(first+Period_Q, 0);
    SM = instance:addInternalStream(first+Period_Q, 0);
    HQ_MA_R = core.indicators:create("EMA", HQ, Period_R);
    HQ_MA_S = core.indicators:create("EMA", HQ_MA_R.DATA, Period_S);
    SM_MA_R = core.indicators:create("EMA", SM, Period_R);
    SM_MA_S = core.indicators:create("EMA", SM_MA_R.DATA, Period_S);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period_Q .. ", " .. instance.parameters.Period_R .. ", " .. instance.parameters.Period_S .. ", " .. instance.parameters.Period_Signal .. ")";
    instance:name(name);
    DataBuff = instance:addStream("DataBuff", core.Line, name .. ".Data", "Data", instance.parameters.DATAclr, first);
    SignalBuff = instance:addStream("SignalBuff", core.Line, name .. ".Signal", "Signal", instance.parameters.SIGNALclr, first);
    sig = core.indicators:create("EMA", DataBuff, Period_Signal);
end

function Update(period, mode)
    if period<first+Period_Q then
    return;
    end
     HQ[period]=core.max(source.high,core.rangeTo(period,Period_Q))-core.min(source.low,core.rangeTo(period,Period_Q));    
     SM[period]=source.close[period]-(core.max(source.high,core.rangeTo(period,Period_Q))+core.min(source.low,core.rangeTo(period,Period_Q)))/2.;
     
    
     HQ_MA_R:update(mode);
     HQ_MA_S:update(mode);  
     SM_MA_R:update(mode);        
     SM_MA_S:update(mode);
     
     if period < SM_MA_S.DATA:first()  or  period < HQ_MA_S.DATA:first() then 
     return;
    end
     
     DataBuff[period]=100.*SM_MA_S.DATA[period]/(0.5*HQ_MA_S.DATA[period]);
     
     sig:update(mode);
     
      if period < sig.DATA:first()then 
      return;
      end
     SignalBuff[period]=sig.DATA[period];
    
end

