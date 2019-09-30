package com.fxtsmobile.indicoreloadindicators.utils;

import com.fxtsmobile.indicoreloadindicators.core.Log;
import com.gehtsoft.indicore3.Parameter;
import com.gehtsoft.indicore3.ParameterValue;
import com.gehtsoft.indicore3.Timezone;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

public class DateUtil {

    private static final String DATE_FORMAT = "MM\\dd\\yyyy";
    private static final String TABLE_DATE_FORMAT = "MM\\dd\\yyyy HH:mm";
    private static final int OLE_YEAR = 1899;

    public static Calendar getParameterCalendar(Parameter parameter) {
        ParameterValue value = parameter.value();

        int days = value.getInteger();
        Calendar date = Calendar.getInstance();

        // days is offset from current date
        if (days < 0) {
            date.add(Calendar.DAY_OF_MONTH, days);
            return date;
        }

        Calendar valueDate = value.getDate();

        if (valueDate != null && valueDate.get(Calendar.YEAR) != OLE_YEAR) {
            // indicore3 uses est time
            valueDate.setTimeZone(Calendar.getInstance().getTimeZone());
            return valueDate;
        }

        return date;
    }

    public static void setDate(ParameterValue parameterValue, Calendar calendar) {
        // to utc-0
        int utcOffset = calendar.get(Calendar.ZONE_OFFSET) + calendar.get(Calendar.DST_OFFSET);
        calendar.add(Calendar.MILLISECOND, -utcOffset);
        // to est
        Calendar estCalendar = Calendar.getInstance(TimeZone.getTimeZone("US/Eastern"));
        int estOffset = estCalendar.get(Calendar.ZONE_OFFSET) + estCalendar.get(Calendar.DST_OFFSET);
        calendar.add(Calendar.MILLISECOND, estOffset);

        parameterValue.setDate(calendar);
    }

    public static String getDateString(Parameter parameter) {
        Calendar date = getParameterCalendar(parameter);

        String formattedDate = "";

        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat(DATE_FORMAT, Locale.getDefault());
            formattedDate = simpleDateFormat.format(date.getTime());
        } catch (Exception e) {
            Log.getInstance().info(e.getMessage());
        }

        return formattedDate;
    }

    public static String getTableDateString(Calendar tableCalendar) {
        String formattedDate = "";

        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat(TABLE_DATE_FORMAT, Locale.getDefault());
            formattedDate = simpleDateFormat.format(tableCalendar.getTime());
        } catch (Exception e) {
            Log.getInstance().info(e.getMessage());
        }

        return formattedDate;
    }

}