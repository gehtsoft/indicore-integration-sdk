package com.fxtsmobile.indicoreloadindicators.model;

import com.gehtsoft.indicore3.OutputStream;

import java.util.ArrayList;
import java.util.List;

public class IndicatorChartConfiguration {

    private List<IndicatorChartItem> indicatorChartItems = new ArrayList<>();
    private int indicatorColor = 0;
    private int lineWidth = 0;
    private OutputStream.LineStyle lineStyle = OutputStream.LineStyle.LineSolid;

    public IndicatorChartConfiguration(List<IndicatorChartItem> indicatorChartItems, int indicatorColor, int lineWidth, OutputStream.LineStyle lineStyle) {
        this.indicatorChartItems = indicatorChartItems;
        this.indicatorColor = indicatorColor;
        this.lineWidth = lineWidth;
        this.lineStyle = lineStyle;
    }

    public List<IndicatorChartItem> getIndicatorChartItems() {
        return indicatorChartItems;
    }

    public int getIndicatorColor() {
        return indicatorColor;
    }

    public int getLineWidth() {
        return lineWidth;
    }

    public OutputStream.LineStyle getLineStyle() {
        return lineStyle;
    }
}
