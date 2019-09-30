package com.fxtsmobile.indicoreloadindicators.core;

public class IndicatorInfo {
    private String indicatorName;
    private String indicatorID;
    private String indicatorType;
    private String requiredSource;

    public IndicatorInfo(String indicatorName, String indicatorID, String indicatorType, String requiredSource) {
        this.indicatorName = indicatorName;
        this.indicatorID = indicatorID;
        this.indicatorType = indicatorType;
        this.requiredSource = requiredSource;
    }

    public String getIndicatorName() {
        return indicatorName;
    }

    public String getIndicatorID() {
        return indicatorID;
    }

    public String getIndicatorType() {
        return indicatorType;
    }

    public String getRequiredSource() {
        return requiredSource;
    }
}
