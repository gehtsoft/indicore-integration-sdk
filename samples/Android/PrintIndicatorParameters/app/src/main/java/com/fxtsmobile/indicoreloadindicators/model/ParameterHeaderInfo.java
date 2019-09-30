package com.fxtsmobile.indicoreloadindicators.model;

public class ParameterHeaderInfo extends ParameterInfo {

    private String name;

    public ParameterHeaderInfo(String name) {
        super(ParameterInfo.TYPE_HEADER);
        this.name = name;
    }

    public String getName() {
        return name;
    }
}
