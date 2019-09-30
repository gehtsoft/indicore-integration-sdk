package com.fxtsmobile.indicoreloadindicators.model;

import com.gehtsoft.indicore3.IndicatorProfile;

import java.util.ArrayList;
import java.util.List;

public class IndicatorData {
    private IndicatorProfile.RequiredSource indicatorRequiredSource;
    private List<CandleChartItem> candleChartItems = new ArrayList<>();
    private List<IndicatorChartConfiguration> indicatorChartConfigurations = new ArrayList<>();

    public IndicatorProfile.RequiredSource getIndicatorRequiredSource() {
        return indicatorRequiredSource;
    }

    public void setIndicatorRequiredSource(IndicatorProfile.RequiredSource indicatorRequiredSource) {
        this.indicatorRequiredSource = indicatorRequiredSource;
    }

    public List<CandleChartItem> getCandleChartItems() {
        return candleChartItems;
    }

    public void setCandleChartItems(List<CandleChartItem> candleChartItems) {
        this.candleChartItems = candleChartItems;
    }

    public List<IndicatorChartConfiguration> getIndicatorChartConfigurations() {
        return indicatorChartConfigurations;
    }

    public void setIndicatorChartConfigurations(List<IndicatorChartConfiguration> indicatorChartConfigurations) {
        this.indicatorChartConfigurations = indicatorChartConfigurations;
    }
}
