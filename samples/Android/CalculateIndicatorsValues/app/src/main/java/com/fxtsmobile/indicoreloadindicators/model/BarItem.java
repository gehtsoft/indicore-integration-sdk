package com.fxtsmobile.indicoreloadindicators.model;

public class BarItem {

    private double low;
    private double close;
    private double open;
    private double high;

    public BarItem(double low, double close, double open, double high) {
        this.low = low;
        this.close = close;
        this.open = open;
        this.high = high;
    }

    public double getLow() {
        return low;
    }

    public double getClose() {
        return close;
    }

    public double getOpen() {
        return open;
    }

    public double getHigh() {
        return high;
    }

}
