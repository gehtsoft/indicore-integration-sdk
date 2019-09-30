package com.fxtsmobile.indicoreloadindicators.core;

import com.gehtsoft.indicore3.IndicoreException;
import com.gehtsoft.indicore3.IndicoreObject;
import com.gehtsoft.indicore3.ValueMap;

import java.util.Calendar;

public class TerminalTest extends com.gehtsoft.indicore3.Terminal {
    @Override
    public boolean alertMessage(IndicoreObject indicoreObject, String s, double v, String s1, Calendar calendar) throws IndicoreException, IllegalStateException {
        return true;
    }

    @Override
    public boolean alertSound(IndicoreObject indicoreObject, String s, boolean b) throws IndicoreException, IllegalStateException {
        return true;
    }

    @Override
    public boolean alertEmail(IndicoreObject indicoreObject, String s, String s1, String s2) throws IndicoreException, IllegalStateException {
        return true;
    }

    @Override
    public String executeOrder(IndicoreObject indicoreObject, int i, ValueMap valueMap) throws IndicoreException, IllegalStateException {
        return null;
    }
}
