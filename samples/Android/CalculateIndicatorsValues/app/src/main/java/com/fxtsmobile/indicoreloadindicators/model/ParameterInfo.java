package com.fxtsmobile.indicoreloadindicators.model;

public class ParameterInfo {
    public static final int TYPE_HEADER = 1;
    public static final int TYPE_DATA = 2;
    public static final int TYPE_COLOR = 3;

    private int type;

    public ParameterInfo(int type) {

        this.type = type;
    }

    public int getType() {
        return type;
    }
}
