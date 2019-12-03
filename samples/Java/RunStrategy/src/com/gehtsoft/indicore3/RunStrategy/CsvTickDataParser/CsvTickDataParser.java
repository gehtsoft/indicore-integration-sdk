package com.gehtsoft.indicore3.RunStrategy.CsvTickDataParser;

import com.gehtsoft.indicore3.TickPriceStorage;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

public class CsvTickDataParser {
    private String mPriceDataPath;
    private String mDelimiter;
    private BufferedReader mBufferedReader;
    private long mLineCount;
    private SimpleDateFormat mSimpleDateFormat;

    public CsvTickDataParser(String priceDataPath) {
        this.mPriceDataPath = priceDataPath;
        this.mDelimiter = ";";
        this.mLineCount = 0;
        this.mSimpleDateFormat = new SimpleDateFormat("MM.dd.yyyy HH:mm:ss");
        this.mSimpleDateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
    }

    public boolean init() throws IOException {

        BufferedReader br = null;
        try {
            br = new BufferedReader(new FileReader(this.mPriceDataPath));
        } catch (FileNotFoundException e) {
            return false;
        }
        while(br.readLine() != null) {
            ++mLineCount;
        }

        mBufferedReader = new BufferedReader(new FileReader(this.mPriceDataPath));
        mBufferedReader.readLine(); //skip first line
        return true;
    }

    public boolean loadNextTick(TickPriceStorage storage) {
        String line;
        try {
            line = mBufferedReader.readLine();
        } catch (IOException ex) {
            return false;
        }

        if (line == null) {
            return false;
        } else {
            String[] values = line.split(this.mDelimiter);
            if (values.length < 3) {
                return false;
            } else {
                Date date;
                try {
                    date = this.mSimpleDateFormat.parse(values[0]);
                } catch (ParseException ex) {
                    return false;
                }

                Calendar cal = Calendar.getInstance();
                cal.setTime(date);
                storage.addTick(cal, Double.parseDouble(values[1]), Double.parseDouble(values[2]), 0.0D);
                return true;
            }
        }
    }

    public long getTicksCount() {
        return mLineCount;
    }

    public boolean loadNextTicks(TickPriceStorage storage, long count) {
        if (count <= 0) {
            return false;
        }

        do
        {
            if (!loadNextTick(storage))
                return false;
            --count;
        } while (count > 0);

        return true;
    }
}
