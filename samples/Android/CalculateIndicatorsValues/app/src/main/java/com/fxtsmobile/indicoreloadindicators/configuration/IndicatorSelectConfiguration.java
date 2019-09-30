package com.fxtsmobile.indicoreloadindicators.configuration;

import android.os.Parcel;
import android.os.Parcelable;

public class IndicatorSelectConfiguration implements Parcelable {

    private int type;
    private int position;

    public IndicatorSelectConfiguration(int type, int position) {

        this.type = type;
        this.position = position;
    }

    public int getType() {
        return type;
    }

    public int getPosition() {
        return position;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(this.type);
        dest.writeInt(this.position);
    }

    protected IndicatorSelectConfiguration(Parcel in) {
        this.type = in.readInt();
        this.position = in.readInt();
    }

    public static final Parcelable.Creator<IndicatorSelectConfiguration> CREATOR = new Parcelable.Creator<IndicatorSelectConfiguration>() {
        @Override
        public IndicatorSelectConfiguration createFromParcel(Parcel source) {
            return new IndicatorSelectConfiguration(source);
        }

        @Override
        public IndicatorSelectConfiguration[] newArray(int size) {
            return new IndicatorSelectConfiguration[size];
        }
    };
}
