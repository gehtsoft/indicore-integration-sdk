package com.fxtsmobile.indicoreloadindicators.model;

import java.util.List;

public class ParameterDataInfo extends ParameterInfo {

    private String name;
    private String valueDescription;
    private List<String> alternatives;

    public ParameterDataInfo(String name, String valueDescription, List<String> alternatives) {
        super(ParameterInfo.TYPE_DATA);
        this.name = name;
        this.valueDescription = valueDescription;
        this.alternatives = alternatives;
    }

    public String getName() {
        return name;
    }

    public String getValueDescription() {
        return valueDescription;
    }

    public List<String> getAlternatives() {
        return alternatives;
    }

}
