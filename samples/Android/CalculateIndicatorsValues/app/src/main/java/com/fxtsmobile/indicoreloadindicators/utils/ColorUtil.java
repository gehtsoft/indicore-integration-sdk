package com.fxtsmobile.indicoreloadindicators.utils;


import android.graphics.Color;

import com.fxtsmobile.indicoreloadindicators.model.RgbColor;

public class ColorUtil {

    public static RgbColor getRgb(int color) {
        int red = (color >> 16) & 255;
        int green = (color >> 8) & 255;
        int blue = color & 255;

        return new RgbColor(red, green, blue);
    }

    public static int getColor(RgbColor rgbColor) {
        return Color.argb(255, rgbColor.getRed(), rgbColor.getGreen(), rgbColor.getBlue());
    }
}
