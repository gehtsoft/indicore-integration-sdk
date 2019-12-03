package com.gehtsoft.indicore3.RunStrategy.Terminal;

import com.gehtsoft.indicore3.IndicoreException;
import com.gehtsoft.indicore3.IndicoreObject;
import com.gehtsoft.indicore3.ValueMap;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

/** Trading console terminal. */
public class ConsoleTerminal extends com.gehtsoft.indicore3.Terminal {

    SimpleDateFormat mDateTimeFormat;

    public ConsoleTerminal()
    {
        mDateTimeFormat = new SimpleDateFormat("MM.dd.yyyy hh:mm");
        mDateTimeFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
    }

    @Override
    public boolean alertMessage(IndicoreObject indicoreObject, String s, double v, String s1, Calendar calendar) throws IndicoreException, IllegalStateException {

        System.out.println(String.format("%s;%s;%2.5f;%s;",s, parseCalendar(calendar), v, s1));
        return true;
    }

    @Override
    public boolean alertSound(IndicoreObject indicoreObject, String s, boolean b) throws IndicoreException, IllegalStateException {

        System.out.println("alertSound");
        return true;
    }

    @Override
    public boolean alertEmail(IndicoreObject indicoreObject, String s, String s1, String s2) throws IndicoreException, IllegalStateException {

        System.out.println("alertEmail");
        return true;
    }

    @Override
    public String executeOrder(IndicoreObject indicoreObject, int i, ValueMap valueMap) throws IndicoreException, IllegalStateException {

        String request_ID = "1";
        System.out.println("executeOrder");
        return request_ID;
    }

    private String parseCalendar(Calendar calendar) {
        Date date = calendar.getTime();
        try {
            return mDateTimeFormat.format(date);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "n/a";
    }

}