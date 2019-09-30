package com.fxtsmobile.indicoreloadindicators.model;

public class ParameterDataInfo extends ParameterInfo {

    private String id;
    private String valueDescription;
    private boolean hasAlternatives;
    private boolean isEditable = true;

    public ParameterDataInfo(String id, String valueDescription, boolean hasAlternatives) {
        super(ParameterInfo.TYPE_DATA);
        this.id = id;
        this.valueDescription = valueDescription;
        this.hasAlternatives = hasAlternatives;
        checkEditAvailability();
    }

    public ParameterDataInfo(int type, String id, String valueDescription, boolean hasAlternatives) {
        super(type);
        this.id = id;
        this.valueDescription = valueDescription;
        this.hasAlternatives = hasAlternatives;
        checkEditAvailability();
    }
    
    /* Disable editing for all line style parameters, to keep things simple assume one is always 'Solid' */
    private void checkEditAvailability() {
        if (valueDescription.toLowerCase().contains("style")) {
            isEditable = false;
            String namePart = this.valueDescription.split("=")[0];
            this.valueDescription = namePart + "= Solid";
        }
    }

    public boolean isEditable() { 
        return isEditable; 
    }

    public String getId() {
        return id;
    }

    public String getValueDescription() {
        return valueDescription;
    }

    public boolean hasAlternatives() {
        return hasAlternatives;
    }
}