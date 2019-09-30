package com.fxtsmobile.indicoreloadindicators.core;

import java.util.Calendar;
import java.util.List;
import java.util.Vector;

public class Log {
    private static Log mInstance = new Log();

    public static Log getInstance() {
        return mInstance;
    }

    private Log() {
    }

    enum LogLevel {
        Debug(0),
        Info(1),
        Warn(2),
        Error(3);

        private int mMass;
        LogLevel(int mass) {
            mMass = mass;
        }

        public int getMass() {
            return mMass;
        }
    }

    public class LogEntity {
        private Calendar mDate;
        private String mMessage;
        private LogLevel mLevel;

        public Calendar getDate() {
            return mDate;
        }

        public String getMessage() {
            return mMessage;
        }

        public LogLevel getLevel() {
            return mLevel;
        }

        LogEntity(String message, LogLevel level) {
            mDate = Calendar.getInstance();
            mMessage = message;
            mLevel = level;
        }

        @Override
        public String toString() {
            return String.format("[%s] %s - %s", mLevel, mDate.getTime(), mMessage);
        }
    }

    Vector<LogEntity> mLog = new Vector<LogEntity>();

    public List<LogEntity> getEntities() {
        return mLog;
    }

    public List<LogEntity> getEntities(LogLevel level) {
        Vector<LogEntity> result = new Vector<LogEntity>();
        for (LogEntity entity : mLog) {
            if (entity.getLevel().getMass() >= level.getMass())
                result.add(entity);
        }
        return result;
    }

    public void clear() {
        mLog.clear();
    }

    public void log(String message, LogLevel level) {
        mLog.add(new LogEntity(message, level));
    }

    public void warn(String message) {
        log(message, LogLevel.Warn);
    }

    public void debug(String message) {
        log(message, LogLevel.Debug);
    }

    public void error(String message) {
        log(message, LogLevel.Error);
    }

    public void info(String message) {
        log(message, LogLevel.Info);
    }

}
