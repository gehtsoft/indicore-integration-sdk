-- 3/29/2016 
-- ADDED parameter SortingMethod
-- ADDED "-" sign in front of negative SSI values

-- 4/18/2016
-- ADDED Color Logic to flip colors if 'Traditional' is selected
-- Changed Color Themes to make them easier to read on various charts

-- IDs for Context objects
local FONT = 1;
local PEN_ZERO = 2;
local PEN_NEG_1 = 3;
local PEN_NEG_2 = 4;
local PEN_NEG_3 = 5;
local PEN_NEG_4 = 6;
local PEN_POS_1 = 7;
local PEN_POS_2 = 8;
local PEN_POS_3 = 9;
local PEN_POS_4 = 10;
local POS_PEN_BAR_BORDER = 11;
local POS_PEN_BAR_BRUSH = 12;
local NEG_PEN_BAR_BORDER = 14;
local NEG_PEN_BAR_BRUSH = 15;
local PEN_WT_DASH = 16;
local FONT_BAR_LABEL = 17;
local symbolDefaults = { "EURUSD","GBPUSD", "USDJPY", "GBPJPY", "EURJPY", "AUDUSD", "XAUUSD", "SPX500", "USDCHF", "USDCAD" };
local symbolParams = { "EURUSD","GBPUSD","USDJPY","GBPJPY","XAUUSD","EURJPY","AUDUSD","SPX500","USDCHF","USDCAD","USOil","NZDUSD","GER30","US30","UK100","EURGBP","EURAUD","AUDJPY","FRA40" };
local SSI_VALUE_PRECISION = 2;

function IsSymbolDefault(symbol)
    for i = 1, table.maxn(symbolDefaults), 1 do
        if symbol == symbolDefaults[i] then return true; end
    end
    return false;
end

function Init()
    indicator:name(resources:get("param_Name"));
    indicator:description(resources:get("param_Description"));
    indicator:setTag("group", "Speculative Sentiment Index (SSI)");
    indicator:type(core.Indicator);
    indicator:requiredSource(core.Tick);
    
    indicator.parameters:addGroup(resources:get("param_StylingGroup"));
    indicator.parameters:addString("SortingMethod", resources:get("param_SortingMethod"), "", "High-to-Low");
        indicator.parameters:addStringAlternative("SortingMethod", resources:get("param_SortingMethod1"), "", "Standard");
        indicator.parameters:addStringAlternative("SortingMethod", resources:get("param_SortingMethod2"), "", "Alphabetically");
        indicator.parameters:addStringAlternative("SortingMethod", resources:get("param_SortingMethod3"), "", "Low-to-High");
        indicator.parameters:addStringAlternative("SortingMethod", resources:get("param_SortingMethod4"), "", "High-to-Low");
    indicator.parameters:addString("THM", resources:get("param_THM"), "", "Light");
        indicator.parameters:addStringAlternative("THM", resources:get("param_THM1"), "", "Light");
        indicator.parameters:addStringAlternative("THM", resources:get("param_THM2"), "", "Dark");
        indicator.parameters:addStringAlternative("THM", resources:get("param_THM3"), "", "Roxbury");
    indicator.parameters:addString("ColorLogic", resources:get("param_ColorLogic"), resources:get("param_ColorLogic_desc"), "Contrarian");
        indicator.parameters:addStringAlternative("ColorLogic", resources:get("param_ColorLogic1"), "", "Contrarian");
        indicator.parameters:addStringAlternative("ColorLogic", resources:get("param_ColorLogic2"), "", "Traditional");
    indicator.parameters:addGroup(resources:get("param_PositionAndSizeGroup"));
    indicator.parameters:addString("DK", resources:get("param_DK"), "", "Bottom-Left");
        indicator.parameters:addStringAlternative("DK", resources:get("param_DK1"), "", "Top-Left");
        indicator.parameters:addStringAlternative("DK", resources:get("param_DK2"), "", "Top-Right");
        indicator.parameters:addStringAlternative("DK", resources:get("param_DK3"), "", "Bottom-Left");
        indicator.parameters:addStringAlternative("DK", resources:get("param_DK4"), "", "Bottom-Right");
    indicator.parameters:addInteger("SSI_VALUE_PRECISION", resources:get("param_SSI_VALUE_PRECISION"), resources:get("param_SSI_VALUE_PRECISION_desc"), 4)    
        indicator.parameters:addIntegerAlternative("SSI_VALUE_PRECISION", "1", "", "1");
        indicator.parameters:addIntegerAlternative("SSI_VALUE_PRECISION", "2", "", "2");
        indicator.parameters:addIntegerAlternative("SSI_VALUE_PRECISION", "3", "", "3");
        indicator.parameters:addIntegerAlternative("SSI_VALUE_PRECISION", "4", "", "4");
    indicator.parameters:addString("FF", resources:get("param_Font"), "", "Calibri");
        indicator.parameters:addStringAlternative("FF", "Times New Roman", "", "Times New Roman");
        indicator.parameters:addStringAlternative("FF", "Arial", "", "Arial");
        indicator.parameters:addStringAlternative("FF", "Calibri", "", "Calibri");
        indicator.parameters:addStringAlternative("FF", "Comic Sans", "", "Comic Sans");
        indicator.parameters:addStringAlternative("FF", "Impact", "", "Impact");
        indicator.parameters:addStringAlternative("FF", "Tahoma", "", "Tahoma");
        indicator.parameters:addStringAlternative("FF", "Verdana", "", "Verdana");
        indicator.parameters:addStringAlternative("FF", "Cambria", "", "Cambria");
    indicator.parameters:addInteger("FS", resources:get("param_FS"), "", 14);
    indicator.parameters:addInteger("M", resources:get("param_M"), "", 14);
    indicator.parameters:addInteger("P", resources:get("param_P"), "", 5);
    indicator.parameters:addInteger("BLFS", resources:get("param_BLFS"), "", 12);
    
    indicator.parameters:addGroup(resources:get("param_SymbolsGroup"));
    for i = 1, table.maxn(symbolParams), 1 do
        indicator.parameters:addBoolean(symbolParams[i], symbolParams[i], "", IsSymbolDefault(symbolParams[i]));
    end
end

local ssi = {};
local ssiValues = {};
local symbolCount;
local fontFace;
local fontSize;
local dock;
local margin;
local padding;
local fontColor;
local posBarBorder;
local posBarBrush;
local negBarBorder;
local negBarBrush;
local barLabelFontSize;
local hashLinesColor;
local barLabelFontColor;
local barLabelFontColorAlt;
local themes = {}
local init;

local SortingMethod;

function isReal()
    local result = false;
    local sessionID = core.host:execute("getTradingProperty", "SessionID", "", "");
    local place = string.find(sessionID, "_");
    if place ~= nill then
        local prefix = string.upper(string.sub(sessionID, 1, place - 1));
        if string.find(prefix, "R") ~= nil then
            result = true;
        end
    end
    return result;
end

function Prepare()
    --assert(isReal(), "This indicator only works with live FXCM accounts");
    require("ssic");
    ssic:init();

    instance:name(profile:id());
    instance:ownerDrawn(true);
    ColorLogic = instance.parameters.ColorLogic;
    fontFace = instance.parameters.FF;
    fontSize = instance.parameters.FS;
    dock = instance.parameters.DK;
    margin = instance.parameters.M;
    padding = instance.parameters.P;
    barLabelFontSize = instance.parameters.BLFS;
    SSI_VALUE_PRECISION = instance.parameters.SSI_VALUE_PRECISION;
    init = false;
    
    if ColorLogic == "Contrarian" then
        themes = {
            ["Color"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(157, 83, 142)
            },
            ["PosBarBorder"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(64, 0, 128)
            },
            ["PosBarBrush"] = {
                ["Dark"] = core.rgb(178, 34, 34),
                ["Light"] = core.rgb(178, 34, 34),
                ["Roxbury"] = core.rgb(157, 83, 142)
            },
            ["NegBarBorder"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(64, 0, 128)
            },
            ["NegBarBrush"] = {
                ["Dark"] = core.rgb(0, 51, 102),
                ["Light"] = core.rgb(0, 128, 0),
                ["Roxbury"] = core.rgb(52, 172, 175)
            },
            ["TitleColor"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(105, 45, 172)
            },
            ["HashLines"] = {
                ["Dark"] = core.rgb(64, 64, 64),
                ["Light"] = core.rgb(212, 212, 212),
                ["Roxbury"] = core.rgb(52, 172, 175)
            },
            ["BarLabelFontColor"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(255, 255, 255),
                ["Roxbury"] = core.rgb(255, 255, 255)
            },
            ["BarLabelFontColorAlt"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(52, 172, 175)
            }
        }
        
    else    
        themes = {
            ["Color"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(157, 83, 142)
            },
            ["PosBarBorder"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(64, 0, 128)
            },
            ["NegBarBrush"] = {
                ["Dark"] = core.rgb(178, 34, 34),
                ["Light"] = core.rgb(178, 34, 34),
                ["Roxbury"] = core.rgb(157, 83, 142)
            },
            ["NegBarBorder"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(64, 0, 128)
            },
            ["PosBarBrush"] = {
                ["Dark"] = core.rgb(0, 51, 102),
                ["Light"] = core.rgb(0, 128, 0),
                ["Roxbury"] = core.rgb(52, 172, 175)
            },
            ["TitleColor"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(105, 45, 172)
            },
            ["HashLines"] = {
                ["Dark"] = core.rgb(64, 64, 64),
                ["Light"] = core.rgb(212, 212, 212),
                ["Roxbury"] = core.rgb(52, 172, 175)
            },
            ["BarLabelFontColor"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(255, 255, 255),
                ["Roxbury"] = core.rgb(255, 255, 255)
            },
            ["BarLabelFontColorAlt"] = {
                ["Dark"] = core.rgb(192, 192, 192),
                ["Light"] = core.rgb(96, 96, 96),
                ["Roxbury"] = core.rgb(52, 172, 175)
            }
        }
    end
    
    SortingMethod = instance.parameters.SortingMethod;
    fontColor = themes.Color[instance.parameters.THM];
    posBarBorder = themes.PosBarBorder[instance.parameters.THM];
    posBarBrush = themes.PosBarBrush[instance.parameters.THM];
    negBarBorder = themes.NegBarBorder[instance.parameters.THM];
    negBarBrush = themes.NegBarBrush[instance.parameters.THM];
    hashLinesColor = themes.HashLines[instance.parameters.THM];
    barLabelFontColor = themes.BarLabelFontColor[instance.parameters.THM];
    barLabelFontColorAlt = themes.BarLabelFontColorAlt[instance.parameters.THM];

    ssi = { };
    for i = 1, table.maxn(symbolParams), 1 do
        if instance.parameters:getBoolean(symbolParams[i]) then
            table.insert(ssi, table.maxn(ssi) + 1, { ["Symbol"] = symbolParams[i], ["SSI"] = 0, ["Success"] = false });
        end
    end
    symbolCount = table.maxn(ssi);
end

function ReleaseInstance()
    ssic:deinit();
end

function GetMinMaxSSI()
    local min, max = 10000000, -10000000;
    for i = 1, symbolCount, 1 do
        if ssi[i].Success then
            if ssi[i].SSI > max then max = ssi[i].SSI end
            if ssi[i].SSI < min then min = ssi[i].SSI end
        end
    end
    return min, max;
end

function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

function format_num(amount, decimal, prefix, neg_prefix)
  local str_amount, formatted, famount, remain

  decimal = decimal or 2  -- default 2 decimal places
  neg_prefix = neg_prefix or "-" -- default negative sign

  famount = math.abs(round(amount, decimal))
  famount = math.floor(famount)

  remain = round(math.abs(amount) - famount, decimal)

  -- comma to separate the thousands
  formatted = comma_value(famount)

  -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain), 3);
    formatted = formatted .. "." .. remain .. string.rep("0", decimal - string.len(remain));
  end

  -- attach prefix string e.g '$' 
  formatted = (prefix or "") .. formatted 

  -- if value is negative then format accordingly
  if (amount < 0) then
    if (neg_prefix == "()") then
      formatted = "("..formatted ..")"
    else
      formatted = neg_prefix .. formatted 
    end
  end

  return formatted
end

function Update(period, mode)
    for i = 1, symbolCount, 1 do
        local success, ssiv = ssic:getSSI(ssi[i].Symbol);
        --core.host:trace(ssi[i].Symbol .. " " .. tostring(success));
        ssi[i].Success = success;
        if success then
            ssi[i].SSI = ssiv;
            init = true;
        end
    end
end

function DrawChartLabel(context, center, columnWidth, text, y)
    local width, height;
    width, height = context:measureText(FONT, text, context.CENTER + context.SINGLELINE + context.VCENTER);
    context:drawText(FONT, text, fontColor, -1, center - columnWidth/2, y, center + columnWidth/2, y + height*2, context.CENTER + context.SINGLELINE + context.VCENTER);
end

function Draw(stage, context)

    -- Symbol column and line label font
    context:createFont(FONT, fontFace, 0, fontSize, 0);
    context:createFont(FONT_BAR_LABEL, fontFace, 0, barLabelFontSize, 0);

    -- Homogeneous color for all lines 
    context:createPen(PEN_WT_DASH, context.DOT, 1, hashLinesColor);
    
    -- 0 line
    context:createPen(PEN_ZERO, context.SOLID, 1, hashLinesColor);
    
    -- Negative levels
    context:createPen(PEN_NEG_1, context.SOLID, 1, core.rgb(255, 0, 0));
    context:createPen(PEN_NEG_2, context.SOLID, 1, core.rgb(255, 51, 51));
    context:createPen(PEN_NEG_3, context.SOLID, 1, core.rgb(255, 102, 102));
    context:createPen(PEN_NEG_4, context.SOLID, 1, core.rgb(255, 153, 153));
    
    -- Positive levels
    context:createPen(PEN_POS_1, context.SOLID, 1, core.rgb(0, 102, 0));
    context:createPen(PEN_POS_2, context.SOLID, 1, core.rgb(0, 153, 76));
    context:createPen(PEN_POS_3, context.SOLID, 1, core.rgb(0, 204, 102));
    context:createPen(PEN_POS_4, context.SOLID, 1, core.rgb(51, 255, 153));
    
    local drawn, textHeight, textWidth, chartWidth, totalHeight, totalWidth = 0, 0, 0, 0, 0, 0;
    for i = 1, symbolCount, 1 do
        if ssi[i].Success then
            drawn = drawn + 1;
            local width, height = context:measureText(1, ssi[i].Symbol, context.RIGHT + context.SINGLELINE + context.VCENTER);
            textWidth = math.max(width, textWidth);
            textHeight = math.max(height, textHeight);
        end
    end
    
    textHeight = textHeight + padding * 2;
    textWidth = textWidth + padding * 2;
    chartWidth = 8 * textWidth / 2; 
    totalHeight = drawn * textHeight;
    totalWidth = textWidth + chartWidth;
    
    local x0, x1, y0, y1 = 0, 0, 0, 0;
    if dock == "Top-Left" then
        x0 = context:left() + margin;
        y0 = context:top() + margin;
        x1 = x0 + totalWidth;
        y1 = y0 + totalHeight;
    elseif dock == "Top-Right" then
        x0 = context:right() - margin - totalWidth;
        y0 = context:top() + margin;
        x1 = x0 + totalWidth;
        y1 = y0 + totalHeight;
    elseif dock == "Bottom-Left" then
        x0 = context:left() + margin;
        y0 = context:bottom() - totalHeight - margin;
        x1 = x0 + totalWidth;
        y1 = y0 + totalHeight;
    else
        x0 = context:right() - totalWidth - margin;
        y0 = context:bottom() - totalHeight - margin;
        x1 = x0 + totalWidth;
        y1 = y0 + totalHeight;
    end
    
    if not(init) then
        local initText = "Initializing . . . ";
        local itWidth, itHeight = context:measureText(1, initText, context.LEFT + context.SINGLELINE + context.VCENTER);
        context:drawText(FONT, initText, fontColor, -1, x0, y0, x0 + itWidth, y0 + itHeight + 2*padding, context.LEFT + context.SINGLELINE + context.VCENTER);
        return;
    end
    
    -- sort table based on SortingMethod
    if SortingMethod == "Low-to-High" then
        table.sort(ssi, function(A, B) return A.SSI < B.SSI end)
    elseif SortingMethod == "High-to-Low" then
        table.sort(ssi, function(A, B) return A.SSI > B.SSI end)
    elseif SortingMethod == "Alphabetically" then
        table.sort(ssi, function(A, B) return A.Symbol < B.Symbol end)
    end
    
    local cy = y0;
    local y = cy;
    for i = 1, symbolCount, 1 do
        if ssi[i].Success then
            context:drawText(FONT, ssi[i].Symbol, fontColor, -1, x0, y, x0 + textWidth, y + textHeight, context.RIGHT + context.SINGLELINE + context.VCENTER);
            y = y + textHeight;
        end
    end
    
    local columnWidth = textWidth / 2;
    local cx0 = x0 + textWidth + padding;
    
    -- Negative lines
    context:drawLine(PEN_WT_DASH, cx0, cy, cx0, y1, transparency);
    context:drawLine(PEN_WT_DASH, cx0 + columnWidth*1, cy, cx0 + columnWidth*1, y1);
    context:drawLine(PEN_WT_DASH, cx0 + columnWidth*2, cy, cx0 + columnWidth*2, y1);
    context:drawLine(PEN_WT_DASH, cx0 + columnWidth*3, cy, cx0 + columnWidth*3, y1);
    
    -- Zero line
    context:drawLine(PEN_ZERO, cx0 + columnWidth*4, cy, cx0 + columnWidth*4, y1);
    
    -- Positive lines
    context:drawLine(PEN_WT_DASH, cx0 + columnWidth*5, cy, cx0 + columnWidth*5, y1);
    context:drawLine(PEN_WT_DASH, cx0 + columnWidth*6, cy, cx0 + columnWidth*6, y1);
    context:drawLine(PEN_WT_DASH, cx0 + columnWidth*7, cy, cx0 + columnWidth*7, y1);
    context:drawLine(PEN_WT_DASH, cx0 + columnWidth*8, cy, cx0 + columnWidth*8, y1);
    
    -- Prepare to create bars
    context:createPen(POS_PEN_BAR_BORDER, context.SOLID, 1, posBarBorder);
    context:createSolidBrush(POS_PEN_BAR_BRUSH, posBarBrush);
    context:createPen(NEG_PEN_BAR_BORDER, context.SOLID, 1, negBarBorder);
    context:createSolidBrush(NEG_PEN_BAR_BRUSH, negBarBrush);
    
    -- Calculate scale of lines
    local mn, mx = GetMinMaxSSI();
    local chartMax = math.floor(math.max(math.abs(mn), mx)) + 1;
    --core.host:trace("Chart max: " .. chartMax);
    local pos4 = chartMax;
    local pos3 = pos4 * 3 / 4;
    local pos2 = pos4 / 2;
    local pos1 = pos4 / 4;
    local neg4 = -chartMax;
    local neg3 = neg4 * 3 / 4;
    local neg2 = neg4 / 2;
    local neg1 = neg4 / 4;
    
    -- Draw labels
    DrawChartLabel(context, cx0 + columnWidth*4, columnWidth, "0", y1);
    DrawChartLabel(context, cx0 + columnWidth*5, columnWidth, pos1, y1);
    DrawChartLabel(context, cx0 + columnWidth*6, columnWidth, pos2, y1);
    DrawChartLabel(context, cx0 + columnWidth*7, columnWidth, pos3, y1);
    DrawChartLabel(context, cx0 + columnWidth*8, columnWidth, pos4, y1);
    DrawChartLabel(context, cx0 + columnWidth*1, columnWidth, neg3, y1);
    DrawChartLabel(context, cx0 + columnWidth*2, columnWidth, neg2, y1);
    DrawChartLabel(context, cx0 + columnWidth*3, columnWidth, neg1, y1);
    DrawChartLabel(context, cx0, columnWidth, neg4, y1);
    
    -- Draw bars
    local zeroX0 = cx0 + columnWidth*4;
    local y = cy;
    

    
    
    for i = 1, symbolCount, 1 do
        if ssi[i].Success then
            local barTop = y + textHeight/8;
            local barBottom = y + textHeight - textHeight/8;
            local barLength = math.abs(ssi[i].SSI) / chartMax * columnWidth * 4;
            if ssi[i].SSI > 0 then
                context:drawRectangle (POS_PEN_BAR_BORDER, POS_PEN_BAR_BRUSH, zeroX0, barTop, zeroX0 + barLength, barBottom);
                local lw, lh = context:measureText(FONT_BAR_LABEL, format_num(ssi[i].SSI, SSI_VALUE_PRECISION, "", ""), context.CENTER + context.SINGLELINE + context.VCENTER);
                if lw > barLength then
                    context:drawText(FONT_BAR_LABEL, format_num(ssi[i].SSI, SSI_VALUE_PRECISION, "", ""), barLabelFontColorAlt, -1, zeroX0 + barLength, barTop, zeroX0 + barLength + lw, barBottom, context.CENTER + context.SINGLELINE + context.VCENTER);
                else 
                    context:drawText(FONT_BAR_LABEL, format_num(ssi[i].SSI, SSI_VALUE_PRECISION, "", ""), barLabelFontColor, -1, zeroX0, barTop, zeroX0 + barLength, barBottom, context.CENTER + context.SINGLELINE + context.VCENTER);
                end
            elseif ssi[i].SSI < 0 then
                context:drawRectangle (NEG_PEN_BAR_BORDER, NEG_PEN_BAR_BRUSH, zeroX0 - barLength, barTop, zeroX0+1, barBottom, transparency);
                local lw, lh = context:measureText(FONT_BAR_LABEL, format_num(ssi[i].SSI, SSI_VALUE_PRECISION, "", "-"), context.CENTER + context.SINGLELINE + context.VCENTER);
                if lw > barLength then
                    context:drawText(FONT_BAR_LABEL, format_num(ssi[i].SSI, SSI_VALUE_PRECISION, "", "-"), barLabelFontColorAlt, -1, zeroX0 - barLength - lw, barTop, zeroX0 - barLength, barBottom, context.CENTER + context.SINGLELINE + context.VCENTER);
                else 
                    context:drawText(FONT_BAR_LABEL, format_num(ssi[i].SSI, SSI_VALUE_PRECISION, "", "-"), barLabelFontColor, -1, zeroX0 - barLength, barTop, zeroX0, barBottom, context.CENTER + context.SINGLELINE + context.VCENTER);
                end
            end
            y = y + textHeight;
        end
    end
    
end
