package com.fxtsmobile.indicoreloadindicators.model;

public class ParameterColorDataInfo extends ParameterDataInfo {

    private final int color;

    public ParameterColorDataInfo(String id, String valueDescription, int color) {
        super(ParameterInfo.TYPE_COLOR, id, valueDescription, false);
        this.color = color;
    }

    public int getColor() {
        return color;
    }
}
