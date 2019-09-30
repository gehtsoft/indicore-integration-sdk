function Init()
    indicator:name(resources:get("R_NAME"));
    indicator:description(resources:get("R_DESCRIPTION"));
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Support/Resistance");

    indicator.parameters:addGroup(resources:get("R_PARAMS"));
    indicator.parameters:addString("BS", resources:get("R_PERIOD"), resources:get("R_PERIOD1"), "D1");
    indicator.parameters:setFlag("BS", core.FLAG_BARPERIODS);

    indicator.parameters:addString("CalcMode", resources:get("R_MODE"), resources:get("R_MODE1"), "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O1"), "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O2"), "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O3"), "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O4"), "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O5"), "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", resources:get("R_MODE_O6"), "", "FibonacciR");

    indicator.parameters:addGroup(resources:get("R_STYLE"));
    indicator.parameters:addString("ShowMode", resources:get("R_SMODE"), resources:get("R_SMODE1"), "TODAY");
    indicator.parameters:addStringAlternative("ShowMode", resources:get("R_SMODE_O1"), "", "TODAY");
    indicator.parameters:addStringAlternative("ShowMode", resources:get("R_SMODE_O2"), "", "HIST");
    indicator.parameters:addString("LabelLoc", resources:get("R_LABEL_LOC"), resources:get("R_LABEL_LOC_DESC"), "E");
    indicator.parameters:addStringAlternative("LabelLoc", resources:get("R_LABEL_LOC_1"), "", "E");
    indicator.parameters:addStringAlternative("LabelLoc", resources:get("R_LABEL_LOC_2"), "", "B");
    indicator.parameters:addStringAlternative("LabelLoc", resources:get("R_LABEL_LOC_3"), "", "A");

    indicator.parameters:addColor("clrP", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_P_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_P_desc")), core.rgb(192, 192, 192));
    indicator.parameters:addInteger("widthP", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_P_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_P_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleP", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_P_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_P_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleP", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrS1", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_S1_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_S1_desc")), core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthS1", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_S1_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_S1_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleS1", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_S1_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_S1_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS1", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS1", resources:get("R_SHOW_S1"), resources:get("R_SHOW_S1_1"), true);

    indicator.parameters:addColor("clrS2", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_S2_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_S2_desc")), core.rgb(224, 0, 0));
    indicator.parameters:addInteger("widthS2", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_S2_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_S2_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleS2", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_S2_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_S2_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS2", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS2", resources:get("R_SHOW_S2"), resources:get("R_SHOW_S2_1"), true);

    indicator.parameters:addColor("clrS3", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_S3_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_S3_desc")), core.rgb(192, 0, 0));
    indicator.parameters:addInteger("widthS3", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_S3_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_S3_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleS3", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_S3_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_S3_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS3", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS3", resources:get("R_SHOW_S3"), resources:get("R_SHOW_S3_1"), true);

    indicator.parameters:addColor("clrS4", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_S4_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_S4_desc")), core.rgb(160, 0, 0));
    indicator.parameters:addInteger("widthS4", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_S4_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_S4_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleS4", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_S4_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_S4_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleS4", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showS4", resources:get("R_SHOW_S4"), resources:get("R_SHOW_S4_1"), true);

    indicator.parameters:addColor("clrR1", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_R1_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_R1_desc")), core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthR1", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_R1_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_R1_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleR1", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_R1_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_R1_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR1", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR1", resources:get("R_SHOW_R1"), resources:get("R_SHOW_R1_1"), true);

    indicator.parameters:addColor("clrR2", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_R2_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_R2_desc")), core.rgb(0, 224, 0));
    indicator.parameters:addInteger("widthR2", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_R2_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_R2_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleR2", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_R2_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_R2_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR2", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR2", resources:get("R_SHOW_R2"), resources:get("R_SHOW_R2_1"), true);

    indicator.parameters:addColor("clrR3", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_R3_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_R3_desc")), core.rgb(0, 192, 0));
    indicator.parameters:addInteger("widthR3", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_R3_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_R3_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleR3", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_R3_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_R3_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR3", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR3", resources:get("R_SHOW_R3"), resources:get("R_SHOW_R3_1"), true);

    indicator.parameters:addColor("clrR4", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_R4_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_R4_desc")), core.rgb(0, 160, 0));
    indicator.parameters:addInteger("widthR4", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_R4_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_R4_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleR4", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_R4_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_R4_desc")), core.LINE_SOLID);
    indicator.parameters:setFlag("styleR4", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("showR4", resources:get("R_SHOW_R4"), resources:get("R_SHOW_R4_1"), true);

    indicator.parameters:addBoolean("ShowMP", resources:get("R_SHOW_MIDPOINT"), resources:get("R_SHOW_MIDPOINT_1"), false);
    indicator.parameters:addColor("clrMP", string.format(resources:get("R_color_of_PARAM_name"), resources:get("R_MIDPOINT_name")),
        string.format(resources:get("R_color_of_PARAM_description"), resources:get("R_MIDPOINT_desc")), core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthMP", string.format(resources:get("R_width_of_PARAM_name"), resources:get("R_MIDPOINT_name")),
        string.format(resources:get("R_width_of_PARAM_description"), resources:get("R_MIDPOINT_desc")), 1, 1, 5);
    indicator.parameters:addInteger("styleMP", string.format(resources:get("R_style_of_PARAM_name"), resources:get("R_MIDPOINT_name")),
        string.format(resources:get("R_style_of_PARAM_description"), resources:get("R_MIDPOINT_desc")), core.LINE_DOT);
    indicator.parameters:setFlag("styleMP", core.FLAG_LEVEL_STYLE);
end

local P;
local H;
local L;
local D;
local source;
local ref;
local instr;
local BS;
local CurrLen;
local BSLen;
local host;
local offset;
local weekoffset;

local RP = 0;
local S1 = 1;
local S2 = 2;
local S3 = 3;
local S4 = 4;
local R1 = 5;
local R2 = 6;
local R3 = 7;
local R4 = 8;
local PID = 9;
local name = {};
local show = {};
local clr = {};
local width = {};
local style = {};
local stream = {};
local fibr = {};

local clrP;
local widthP;
local styleP;

local O_PIVOT = 1;
local O_CAM = 2;
local O_WOOD = 3;
local O_FIB = 4;
local O_FLOOR = 5;
local O_FIBR = 6;
local CalcMode;

local O_HIST = 1;
local O_TODAY = 2;
local ShowMode;
local ShowMP;
local clrMP;
local widthMP;
local styleMP;
local O_END = 1;
local O_BEG = 2;
local O_BOTH = 3;
local LabelLoc;
local eps;
local SameSizeBar = false;
local loading = false;

if ffi then
    local ffi_caller;
    local ffi_host;
    local ffi_ref
    local ffi_source;
    local ffi_ref;
    local ffi_ref_open;
    local ffi_ref_high;
    local ffi_ref_close;
    local ffi_ref_low;
    local ffi_P;
    local ffi_H;
    local ffi_L;
    local pv;
end
    local ffi_stream = {};

function Prepare(onlyName)
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    source = instance.source;
    instr = source:instrument();
    BS = instance.parameters.BS;
    clrP = instance.parameters.clrP;
    widthP = instance.parameters.widthP;
    styleP = instance.parameters.styleP;
    ShowMP = instance.parameters.ShowMP;
    clrMP = instance.parameters.clrMP;
    widthMP = instance.parameters.widthMP;
    styleMP = instance.parameters.styleMP;

    local precision = source:getPrecision();
    if precision > 0 then
        eps = math.pow(10, -precision);
    else
        eps = 1;
    end

    name[RP] = "P";
    name[S1] = "S1";
    name[S2] = "S2";
    name[S3] = "S3";
    name[S4] = "S4";
    name[R1] = "R1";
    name[R2] = "R2";
    name[R3] = "R3";
    name[R4] = "R4";
    show[S1] = instance.parameters.showS1;
    show[S2] = instance.parameters.showS2;
    show[S3] = instance.parameters.showS3;
    show[S4] = instance.parameters.showS4;
    show[R1] = instance.parameters.showR1;
    show[R2] = instance.parameters.showR2;
    show[R3] = instance.parameters.showR3;
    show[R4] = instance.parameters.showR4;
    clr[S1] = instance.parameters.clrS1;
    clr[S2] = instance.parameters.clrS2;
    clr[S3] = instance.parameters.clrS3;
    clr[S4] = instance.parameters.clrS4;
    clr[R1] = instance.parameters.clrR1;
    clr[R2] = instance.parameters.clrR2;
    clr[R3] = instance.parameters.clrR3;
    clr[R4] = instance.parameters.clrR4;
    width[S1] = instance.parameters.widthS1;
    width[S2] = instance.parameters.widthS2;
    width[S3] = instance.parameters.widthS3;
    width[S4] = instance.parameters.widthS4;
    width[R1] = instance.parameters.widthR1;
    width[R2] = instance.parameters.widthR2;
    width[R3] = instance.parameters.widthR3;
    width[R4] = instance.parameters.widthR4;
    style[S1] = instance.parameters.styleS1;
    style[S2] = instance.parameters.styleS2;
    style[S3] = instance.parameters.styleS3;
    style[S4] = instance.parameters.styleS4;
    style[R1] = instance.parameters.styleR1;
    style[R2] = instance.parameters.styleR2;
    style[R3] = instance.parameters.styleR3;
    style[R4] = instance.parameters.styleR4;

    fibr[S4] = -0.272;
    fibr[S3] = 0;
    fibr[S2] = 0.236;
    fibr[S1] = 0.382;
    fibr[R1] = 0.618;
    fibr[R2] = 0.764;
    fibr[R3] = 1;
    fibr[R4] = 1.272;

    -- validate
    local l1, l2;
    local s, e;

    s, e = core.getcandle(source:barSize(), core.now(), 0);
    l1 = e - s;
    s, e = core.getcandle(BS, core.now(), 0);
    l2 = e - s;
    BSLen = l2; -- remember length of the period
    CurrLen = l1;

    if source:barSize() == BS then
        SameSizeBar = true;
    end


    if instance.parameters.ShowMode == "TODAY" then
        ShowMode = O_TODAY;
    elseif instance.parameters.ShowMode == "HIST" then
        ShowMode = O_HIST;
    else
        assert(false, resources:get("R_SMODE_ERR") .. ": " .. instance.parameters.CalcMode);
    end

    if instance.parameters.CalcMode == "Pivot" then
        CalcMode = O_PIVOT;
    elseif instance.parameters.CalcMode == "Camarilla" then
        CalcMode = O_CAM;
    elseif instance.parameters.CalcMode == "Woodie" then
        CalcMode = O_WOOD;
    elseif instance.parameters.CalcMode == "Fibonacci" then
        CalcMode = O_FIB;
    elseif instance.parameters.CalcMode == "Floor" then
        CalcMode = O_FLOOR;
    elseif instance.parameters.CalcMode == "FibonacciR" then
        CalcMode = O_FIBR;
        if ShowMode == O_TODAY then
            name[S1] = tostring(fibr[S1]);
            name[S2] = tostring(fibr[S2]);
            name[S3] = tostring(fibr[S3]);
            name[S4] = tostring(fibr[S4]);
            name[R1] = tostring(fibr[R1]);
            name[R2] = tostring(fibr[R2]);
            name[R3] = tostring(fibr[R3]);
            name[R4] = tostring(fibr[R4]);
            name[RP] = "0.5";
        end
    else
        assert(false, resources:get("R_MODE_ERR") .. ": " .. instance.parameters.CalcMode);
    end


    if instance.parameters.LabelLoc == "E" then
        LabelLoc = O_END;
    elseif instance.parameters.LabelLoc == "B" then
        LabelLoc = O_BEG;
    elseif instance.parameters.LabelLoc == "A" then
        LabelLoc = O_BOTH;
    else
        assert(false, resources:get("L_LABEL_LOC_ERR") .. ": " .. instance.parameters.LabelLoc);
    end

    if ffi then
        pv = ffi.typeof("void *");
        ffi_caller = ffi.cast(pv, instance.ffi_ptr);
        ffi_host = ffi.cast(pv, core.host.ffi_ptr);
        ffi_source = ffi.cast(pv, source.ffi_ptr);
    end

    -- create streams
    local sname;
    sname = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.CalcMode .. ")";
    instance:name(sname);

    if onlyName then
        assert(l1 <= l2, resources:get("R_PERIOD_ERR1"));
        assert(BS ~= "t1", resources:get("R_PERIOD_ERR2"));
        return;
    end

    -- pivot
    if ShowMode == O_HIST then
        P = instance:addStream("P", core.Line, sname .. "." .. "P", "P", clrP, 0);
        P:setWidth(widthP);
        P:setStyle(styleP);
    else
        D = instance:addInternalStream(0, 0);
        D:setWidth(widthP);
        D:setStyle(styleP);
        P = instance:addInternalStream(0, 0);
    end
    -- range
    H = instance:addInternalStream(0, 0);
    L = instance:addInternalStream(0, 0);
    -- show stream for historical mode
    if ShowMode == O_HIST then
        for i = S1, R4, 1 do
            if show[i] then
                stream[i] = instance:addStream(name[i], core.Line, sname .. "." .. name[i], name[i], clr[i], 0);
                stream[i]:setWidth(width[i]);
                stream[i]:setStyle(style[i]);
            if ffi then
                ffi_stream[i] = ffi.cast(pv, stream[i] .ffi_ptr);
            end

            end
        end
    end

    ref = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), 10, 100, 101);
    if ffi then
        ffi_ref = ffi.cast(pv, ref.ffi_ptr);
        ffi_ref_open = ffi.cast(pv, ref.open.ffi_ptr);
        ffi_ref_high = ffi.cast(pv, ref.high.ffi_ptr);
        ffi_ref_close = ffi.cast(pv, ref.close.ffi_ptr);
        ffi_ref_low = ffi.cast(pv, ref.low.ffi_ptr);
        ffi_P = ffi.cast(pv, P.ffi_ptr);
        ffi_H = ffi.cast(pv, H.ffi_ptr);
        ffi_L = ffi.cast(pv, L.ffi_ptr);
    end

    loading = true;
end

local pday = nil;
local d = {};
local canWork = nil;

if ffi then 

function Update(period, mode)
    if canWork == nil then
        if CurrLen > BSLen then
            core.host:execute("setStatus", resources:get("R_PERIOD_ERR1"));
            canWork = false;
            return ;
        elseif BS == "t1" then
            core.host:execute("setStatus", resources:get("R_PERIOD_ERR2"));
            canWork = false;
            return ;
        else
            canWork = true;
        end
    elseif not(canWork) then
       
        return ;
    end

    -- get the previous's candle and load the ref data in case ref data does not exist
    local candle;

    local parsedCandle = indicore3_ffi.core_parseCandle(BS);


    candle = indicore3_ffi.core_getCandle(parsedCandle,
                                          indicore3_ffi.stream_date(ffi_source, period),
                                          offset,
                                          weekoffset,
                                          nil);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading then
        return ;
    end
        
    local ref_size = indicore3_ffi.stream_size(ffi_ref);

    if ref_size == 0 then
        return;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (candle < indicore3_ffi.stream_date(ffi_ref, 0) ) then
        return ;
    end

    -- find the lastest completed period which is not saturday's period (to avoid
    -- collecting the saturday's data
    local prev_i = nil;
    local start;

    if (pday == nil) then
        start = 0;
    elseif indicore3_ffi.stream_date(ffi_ref, pday) >= candle then
        start = 0;
    else
        start = pday;
    end

    for i = start, ref_size - 1, 1 do
        -- skip nontrading candles
        local date = indicore3_ffi.stream_date(ffi_ref, i);
        if BSLen > 1 or indicore3_ffi.core_isNonTrading(date, offset) == -1 then
            if (date >= candle) then
                break;
            else
                prev_i = i;
            end
        end
    end

    if (prev_i == nil) then
        -- assert(false, "prev_i is nil");
        return ;
    end

    pday = prev_i;
    if CalcMode == O_PIVOT or CalcMode == O_FIB or CalcMode == O_FLOOR then
        indicore3_ffi.outputstreamimpl_set(ffi_P, 
                                           period, 
                                           (indicore3_ffi.stream_getPrice(ffi_ref_high, prev_i) + 
                                            indicore3_ffi.stream_getPrice(ffi_ref_close, prev_i) + 
                                            indicore3_ffi.stream_getPrice(ffi_ref_low, prev_i))/3);
    elseif CalcMode == O_CAM then
        P[period] = ref.close[prev_i];
        indicore3_ffi.outputstreamimpl_set(ffi_P, 
                                           period, 
                                           indicore3_ffi.stream_getPrice(ffi_ref_close, prev_i)); 
    elseif CalcMode == O_FIBR then
        indicore3_ffi.outputstreamimpl_set(ffi_P, 
                                           period, 
                                           (indicore3_ffi.stream_getPrice(ffi_ref_high, prev_i) + 
                                            indicore3_ffi.stream_getPrice(ffi_ref_low, prev_i))/2);

    elseif CalcMode == O_WOOD then
        local open;
        if (prev_i == ref_size - 1) then
            -- for a live day take close as open of the next period
            open = indicore3_ffi.stream_getPrice(ffi_ref_open, prev_i); 

        else
            open = indicore3_ffi.stream_getPrice(ffi_ref_open, prev_i + 1); 
        end

        indicore3_ffi.outputstreamimpl_set(ffi_P, 
                                           period, 
                                           (indicore3_ffi.stream_getPrice(ffi_ref_high, prev_i) + 
                                            indicore3_ffi.stream_getPrice(ffi_ref_low, prev_i) +
                                            open * 2 ) / 4);
    end

    indicore3_ffi.outputstreamimpl_set(ffi_H, 
                                        period, 
                                        indicore3_ffi.stream_getPrice(ffi_ref_high, prev_i));

    indicore3_ffi.outputstreamimpl_set(ffi_L, 
                                        period, 
                                        indicore3_ffi.stream_getPrice(ffi_ref_low, prev_i));

    CalculateLevels(period);

    if ShowMode == O_HIST then
        local nb;
        nb = false;

        local abs = indicore3_ffi.stream_getPrice(ffi_P, period - 1) -
                    indicore3_ffi.stream_getPrice(ffi_P, period);
        if abs < 0 then 
           abs = -abs;
        end

        if indicore3_ffi.stream_hasData(ffi_P, period - 1) and abs > eps and not(SameSizeBar) then
            nb = true;
        end

        for i = S1, R4, 1 do
            if show[i] and d[i] ~= 0 then
                indicore3_ffi.outputstreamimpl_set(ffi_stream[i], period, d[i]);
		
                if nb then
                indicore3_ffi.outputstreamimpl_setBreak(ffi_stream[i], period, true);
                end
            end
        end
    end
    if (period == indicore3_ffi.stream_size(ffi_source) - 1) then
        ShowLevels(d, period);
    end
end

function initCalculateLevel(period)

    local h, l, p, r;
    p = indicore3_ffi.stream_getPrice(ffi_P, period);
    h = indicore3_ffi.stream_getPrice(ffi_H, period);
    l = indicore3_ffi.stream_getPrice(ffi_L, period);
    r = h - l;
    return h, l, p, r;
end

function ShowLevels(data, period)
    local i, d1, d2;

    d2 = indicore3_ffi.stream_date(ffi_source, period);

    local parsedCandle = indicore3_ffi.core_parseCandle(BS);

    local d3 = ffi.new("double[1]", 0.0);
    d1 = indicore3_ffi.core_getCandle(parsedCandle,
                                      d2,
                                      offset,
                                      weekoffset,
                                      d3);
    d2 = d3[0];

    local precision = indicore3_ffi.stream_precision(ffi_source);
    host:execute("drawLine", PID, d1, P[period], d2, P[period], clrP, styleP, widthP, "P(" .. round(P[period], precision) .. ")");
    if LabelLoc == O_END or LabelLoc == O_BOTH then
        host:execute("drawLabel", PID, d2, P[period], name[RP]);
    end
    if LabelLoc == O_BEG or LabelLoc == O_BOTH then
        host:execute("drawLabel", PID + 100, d1, P[period], name[RP]);
    end

    for i = S1, R4, 1 do
        if show[i] and data[i] ~= 0 then
            host:execute("drawLine", i, d1, data[i], d2, data[i], clr[i], style[i], width[i], name[i] .. "(" .. round(data[i], precision) .. ")");
            if LabelLoc == O_END or LabelLoc == O_BOTH then
                host:execute("drawLabel", i, d2, data[i], name[i]);
            end
            if LabelLoc == O_BEG or LabelLoc == O_BOTH then
                host:execute("drawLabel", i + 100, d1, data[i], name[i]);
            end
        else
            host:execute("removeLine", i);
            host:execute("removeLabel", i);
            host:execute("removeLabel", i + 100);
        end
    end

    if ShowMP then
        ShowMPP(0, d1, d2, d[S2], d[S3], "M0");
        ShowMPP(1, d1, d2, d[S1], d[S2], "M1");
        ShowMPP(2, d1, d2, price, d[S1], "M2");
        ShowMPP(3, d1, d2, price, d[R1], "M3");
        ShowMPP(4, d1, d2, d[R1], d[R2], "M4");
        ShowMPP(5, d1, d2, d[R2], d[R3], "M5");
    end
end

function ShowMPP(i, d1, d2, p1, p2, l)
    local precision = indicore3_ffi.stream_precision(ffi_source);
    if p1 ~= 0 and p2 ~= 0 then
        local p = (p1 + p2) / 2;
        host:execute("drawLine", PID + 10 + i, d1, p, d2, p, clrMP, styleMP, widthMP, l .. "(" .. round(p, precision) .. ")");
        if LabelLoc == O_END or LabelLoc == O_BOTH then
            host:execute("drawLabel", PID + 10 + i, d2, p, l);
        end
        if LabelLoc == O_BEG or LabelLoc == O_BOTH then
            host:execute("drawLabel", PID + 110 + i, d1, p, l);
        end
    end
end

else

function Update(period, mode)
    if canWork == nil then
        if CurrLen > BSLen then
            core.host:execute("setStatus", resources:get("R_PERIOD_ERR1"));
            canWork = false;
            return ;
        elseif BS == "t1" then
            core.host:execute("setStatus", resources:get("R_PERIOD_ERR2"));
            canWork = false;
            return ;
        else
            canWork = true;
        end
    elseif not(canWork) then
        return ;
    end

    -- get the previous's candle and load the ref data in case ref data does not exist
    local candle;
    candle = core.getcandle(BS, source:date(period), offset, weekoffset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading then
        return ;
    end

    if ref:size() == 0 then
        return;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (candle < ref:date(0)) then
        return ;
    end

    -- find the lastest completed period which is not saturday's period (to avoid
    -- collecting the saturday's data
    local prev_i = nil;
    local start;

    if (pday == nil) then
        start = 0;
    elseif ref:date(pday) >= candle then
        start = 0;
    else
        start = pday;
    end

    for i = start, ref:size() - 1, 1 do
        local td;
        -- skip nontrading candles
        if BSLen > 1 or not(core.isnontrading(ref:date(i), offset)) then
            if (ref:date(i) >= candle) then
                break;
            else
                prev_i = i;
            end
        end
    end

    if (prev_i == nil) then
        -- assert(false, "prev_i is nil");
        return ;
    end

    pday = prev_i;
    if CalcMode == O_PIVOT or CalcMode == O_FIB or CalcMode == O_FLOOR then
        P[period] = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3;
    elseif CalcMode == O_CAM then
        -- P[period] = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3;
        P[period] = ref.close[prev_i];
    elseif CalcMode == O_FIBR then
        P[period] = (ref.high[prev_i] + ref.low[prev_i]) / 2;
    elseif CalcMode == O_WOOD then
        local open;
        if (prev_i == ref:size() - 1) then
            -- for a live day take close as open of the next period
            open = ref.open[prev_i];
        else
            open = ref.open[prev_i + 1];
        end
        P[period] = (ref.high[prev_i] + ref.low[prev_i] + open * 2 ) / 4;
    end
    H[period] = ref.high[prev_i];
    L[period] = ref.low[prev_i];


    CalculateLevels(period);
    if ShowMode == O_HIST then
        local nb;
        nb = false;
        if P:hasData(period - 1) and math.abs(P[period - 1] - P[period]) > eps and not(SameSizeBar) then
            nb = true;
        end

        for i = S1, R4, 1 do
            if show[i] and d[i] ~= 0 then
                stream[i][period] = d[i];
                if nb then
                    stream[i]:setBreak(period, true);
                end
            end
        end
    end
    if (period == source:size() - 1) then
        ShowLevels(d, period);
    end
end

function initCalculateLevel(period)

    local h, l, p, r;

    p = P[period];
    h = H[period];
    l = L[period];
    r = h - l;
    return h, l, p, r;
end

function ShowLevels(data, period)
    local i, d1, d2;

    --d1 = source:date(0);
    d2 = source:date(period);
    d1, d2 = core.getcandle(BS, d2, offset, weekoffset);

    host:execute("drawLine", PID, d1, P[period], d2, P[period], clrP, styleP, widthP, "P(" .. round(P[period], source:getPrecision()) .. ")");
    if LabelLoc == O_END or LabelLoc == O_BOTH then
        host:execute("drawLabel", PID, d2, P[period], name[RP]);
    end
    if LabelLoc == O_BEG or LabelLoc == O_BOTH then
        host:execute("drawLabel", PID + 100, d1, P[period], name[RP]);
    end

    for i = S1, R4, 1 do
        if show[i] and data[i] ~= 0 then
            host:execute("drawLine", i, d1, data[i], d2, data[i], clr[i], style[i], width[i], name[i] .. "(" .. round(data[i], source:getPrecision()) .. ")");
            if LabelLoc == O_END or LabelLoc == O_BOTH then
                host:execute("drawLabel", i, d2, data[i], name[i]);
            end
            if LabelLoc == O_BEG or LabelLoc == O_BOTH then
                host:execute("drawLabel", i + 100, d1, data[i], name[i]);
            end
        else
            host:execute("removeLine", i);
            host:execute("removeLabel", i);
            host:execute("removeLabel", i + 100);
        end
    end

    if ShowMP then
        ShowMPP(0, d1, d2, d[S2], d[S3], "M0");
        ShowMPP(1, d1, d2, d[S1], d[S2], "M1");
        ShowMPP(2, d1, d2, P[period], d[S1], "M2");
        ShowMPP(3, d1, d2, P[period], d[R1], "M3");
        ShowMPP(4, d1, d2, d[R1], d[R2], "M4");
        ShowMPP(5, d1, d2, d[R2], d[R3], "M5");
    end
end

function ShowMPP(i, d1, d2, p1, p2, l)
    if p1 ~= 0 and p2 ~= 0 then
        local p = (p1 + p2) / 2;
        host:execute("drawLine", PID + 10 + i, d1, p, d2, p, clrMP, styleMP, widthMP, l .. "(" .. round(p, source:getPrecision()) .. ")");
        if LabelLoc == O_END or LabelLoc == O_BOTH then
            host:execute("drawLabel", PID + 10 + i, d2, p, l);
        end
        if LabelLoc == O_BEG or LabelLoc == O_BOTH then
            host:execute("drawLabel", PID + 110 + i, d1, p, l);
        end
    end
end

end
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        pday = nil;
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


function CalculateLevels(period)
    
    local h, l, p, r = initCalculateLevel(period);

    if CalcMode == O_PIVOT then
        d[R4] = p + r * 3;
        d[R3] = p + r * 2;
        d[R2] = p + r;
        d[R1] = p * 2 - l;

        d[S1] = p * 2 - h;
        d[S2] = p - r;
        d[S3] = p - r * 2;
        d[S4] = p - r * 3;
    elseif CalcMode == O_CAM then
        d[R4] = p + r * 1.1 / 2;
        d[R3] = p + r * 1.1 / 4;
        d[R2] = p + r * 1.1 / 6;
        d[R1] = p + r * 1.1 / 12;

        d[S1] = p - r * 1.1 / 12;
        d[S2] = p - r * 1.1 / 6;
        d[S3] = p - r * 1.1 / 4;
        d[S4] = p - r * 1.1 / 2;
    elseif CalcMode == O_WOOD then
        d[R4] = h + (2 * (p - l) + r);
        d[R3] = h + 2 * (p - l);
        d[R2] = p + r;
        d[R1] = p * 2 - l;

        d[S1] = p * 2 - h;
        d[S2] = p - r;
        d[S3] = l - 2 * (h - p);
        d[S4] = l - (r + 2 * (h - p));
    elseif CalcMode == O_FIB then
        d[R4] = p + 1.618 * (h - l);
        d[R3] = p + 1 * (h - l);
        d[R2] = p + 0.618 * (h - l);
        d[R1] = p + 0.382 * (h - l);

        d[S1] = p - 0.382 * (h - l);
        d[S2] = p - 0.618 * (h - l);
        d[S3] = p - 1 * (h - l);
        d[S4] = p - 1.618 * (h - l);
    elseif CalcMode == O_FLOOR then
        d[R4] = 0;
        d[R3] = h + (p - l) * 2;
        d[R2] = p + r;
        d[R1] = p * 2 - l;

        d[S1] = p * 2 - h;
        d[S2] = p - r;
        d[S3] = l - (h - p) * 2;
        d[S4] = 0;
    elseif CalcMode == O_FIBR then
        d[R4] = l + (h - l) * fibr[R4];
        d[R3] = l + (h - l) * fibr[R3];
        d[R2] = l + (h - l) * fibr[R2];
        d[R1] = l + (h - l) * fibr[R1];

        d[S1] = l + (h - l) * fibr[S1];
        d[S2] = l + (h - l) * fibr[S2];
        d[S3] = l + (h - l) * fibr[S3];
        d[S4] = l + (h - l) * fibr[S4];
    end

    return ;
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
