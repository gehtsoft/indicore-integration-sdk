package com.fxtsmobile.indicoreloadindicators.core;

import com.gehtsoft.indicore3.IndicatorProfile;

import java.util.ArrayList;
import java.util.List;

public class SharedObjects {

    private List<IndicatorProfile> standardIndicatorProfiles = new ArrayList<>();
    private List<IndicatorProfile> customIndicatorProfiles = new ArrayList<>();

    private static SharedObjects mInstance;

    public static SharedObjects getInstance() {
        if (mInstance == null) {
            mInstance = new SharedObjects();
        }
        return mInstance;
    }

    public List<IndicatorProfile> getStandardIndicatorProfiles() {
        return standardIndicatorProfiles;
    }

    public void setStandardIndicatorProfiles(List<IndicatorProfile> standardIndicatorProfiles) {
        this.standardIndicatorProfiles = standardIndicatorProfiles;
    }

    public List<IndicatorProfile> getCustomIndicatorProfiles() {
        return customIndicatorProfiles;
    }

    public void setCustomIndicatorProfiles(List<IndicatorProfile> customIndicatorProfiles) {
        this.customIndicatorProfiles = customIndicatorProfiles;
    }
}