package com.fxtsmobile.indicoreloadindicators.model;

import java.util.Calendar;

public class IndicatorChartItem {

    private final double price;
    private final Calendar calendar;

    public IndicatorChartItem(double price, Calendar calendar) {

        this.price = price;
        this.calendar = calendar;
    }

    public double getPrice() {
        return price;
    }

    public Calendar getCalendar() {
        return calendar;
    }
}