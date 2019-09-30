function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("T", resources:get("param_T_name"), resources:get("param_T_description"), "0");
    indicator.parameters:addStringAlternative("T", resources:get("string_alternative_T_Time"), "", "0");
    indicator.parameters:addStringAlternative("T", resources:get("string_alternative_T_Percentage"), "", "1");
    indicator.parameters:addStringAlternative("T", resources:get("string_alternative_T_Both"), "", "2");
    indicator.parameters:addColor("FC", string.format(resources:get("R_color_of_PARAM_name"), resources:get("param_FC_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("param_FC_desc")), core.COLOR_LABEL);
end

local source;
local len;
local out;
local L;
local T;
local tid;

function Prepare(onlyName)
    source = instance.source;
    assert(source:isAlive(), resources:get("assert_livePrice"));
    assert(source:barSize() ~= "t1", resources:get("assert_bar"));
    local name = profile:id() .. "(" .. source:name() .. ")";

    instance:name(name);

    if onlyName then
        return ;
    end

    T = tonumber(instance.parameters.T);
    L = instance.parameters.L;

    local s, e;

    -- calculate length of the bar in seconds
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
    len = math.floor((e - s) * 86400 + 0.5);
    out = instance:addStream("O", core.Line, "O", "O", instance.parameters.FC, 0);
    tid = core.host:execute("setTimer", 1, 1);
end

function Update(period, mode)
    return ;
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 and source:size() > 1 then
        local period = source:size() - 1;

        -- calculate offset b/w the current time and the
        -- the server time

        -- get current date/time
        local now = core.host:execute("getServerTime", 1);
        --core.host:trace(core.formatDate(now));

        -- calculate how much seconds past from the beginning of the candle
        local past;
        past = math.floor((now - source:date(period)) * 86400 + 0.5);
        local percents;
        percents = math.floor(past / len * 100);

        -- calculate how much seconds remains:
        past = len - past;
        if past > 0 then
            local h, m, s, t, p, n;
            s = math.floor(past % 60);
            m = math.floor((past / 60)) % 60;
            h = math.floor(past / 3600);

            if T == 0 then
                t = string.format("%i:%02i:%02i", h, m, s);
            elseif T == 1 then
                t = string.format("%i%%", percents);
            elseif T == 2 then
                t = string.format("%i:%02i:%02i %i%%", h, m, s, percents);
            end

            core.host:execute("setStatus", t);
        else
            core.host:execute("setStatus", "");
        end
        return core.ASYNC_REDRAW;
    end
    return 0;
end

function ReleaseInstance()
    core.host:execute("killTimer", tid);
end
