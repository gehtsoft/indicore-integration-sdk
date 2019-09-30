package com.fxtsmobile.indicoreloadindicators.model;

import java.util.Calendar;

public class CandleChartItem {
    private BarItem barItem;
    private Calendar calendar;

    public CandleChartItem(BarItem barItem, Calendar calendar) {
        this.barItem = barItem;
        this.calendar = calendar;
    }

    public BarItem getBarItem() {
        return barItem;
    }

    public Calendar getCalendar() {
        return calendar;
    }

}
