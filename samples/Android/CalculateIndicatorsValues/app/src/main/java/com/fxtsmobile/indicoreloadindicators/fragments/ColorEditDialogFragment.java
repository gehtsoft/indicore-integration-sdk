package com.fxtsmobile.indicoreloadindicators.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SeekBar;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.model.RgbColor;
import com.fxtsmobile.indicoreloadindicators.utils.ColorUtil;

public class ColorEditDialogFragment extends ParameterEditDialogFragment<Integer> {

    private View colorView;
    private SeekBar rSeekBar;
    private SeekBar gSeekBar;
    private SeekBar bSeekBar;

    private TextView rValueTextView;
    private TextView gValueTextView;
    private TextView bValueTextView;

    private RgbColor rgb;

    public static ColorEditDialogFragment newInstance() {
        return new ColorEditDialogFragment();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_dialog_color_edit, container, false);

        parameterNameTextView = view.findViewById(R.id.parameterNameTextView);
        confirmButton = view.findViewById(R.id.okButton);

        colorView = view.findViewById(R.id.colorView);
        rValueTextView = view.findViewById(R.id.rValueTextView);
        gValueTextView = view.findViewById(R.id.gValueTextView);
        bValueTextView = view.findViewById(R.id.bValueTextView);
        rSeekBar = view.findViewById(R.id.rSeekBar);
        gSeekBar = view.findViewById(R.id.gSeekBar);
        bSeekBar = view.findViewById(R.id.bSeekBar);

        return view;
    }

    private SeekBar.OnSeekBarChangeListener onSeekBarChangeListener = new SeekBar.OnSeekBarChangeListener() {
        @Override
        public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
            setSeekBarValue(seekBar, i, false);
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
        }

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
            refreshColorView();
        }
    };

    @Override
    Integer getInitialValue() {
        return parameter.value().getColor();
    }

    @Override
    protected void onEditCompleted() {
        editValue = ColorUtil.getColor(rgb);
        super.onEditCompleted();
    }

    private void refreshColorView() {
        colorView.setBackgroundColor(ColorUtil.getColor(rgb));
    }

    private void setSeekBarValue(SeekBar seekBar, int value, boolean isForced) {
        TextView textView = null;

        if (seekBar.getId() == rSeekBar.getId()) {
            textView = rValueTextView;
            rgb.setRed(value);
        }
        if (seekBar.getId() == gSeekBar.getId()) {
            textView = gValueTextView;
            rgb.setGreen(value);
        }
        if (seekBar.getId() == bSeekBar.getId()) {
            textView = bValueTextView;
            rgb.setBlue(value);
        }

        if (textView != null) {
            textView.setText(getSeekValueText(value));
        }

        if (isForced) {
            seekBar.setProgress(value);
        }
    }

    private String getSeekValueText(int source) {
        String text = String.valueOf(source);
        int textLength = text.length();

        if (textLength == 1) {
            text = "00" + text;
        } else if (textLength == 2) {
            text = "0" + text;
        }

        return text;
    }

    @Override
    protected void setup() {
        super.setup();
        rgb = ColorUtil.getRgb(getInitialValue());

        setSeekBarValue(rSeekBar, rgb.getRed(), true);
        setSeekBarValue(gSeekBar, rgb.getGreen(), true);
        setSeekBarValue(bSeekBar, rgb.getBlue(), true);

        refreshColorView();

        rSeekBar.setOnSeekBarChangeListener(onSeekBarChangeListener);
        gSeekBar.setOnSeekBarChangeListener(onSeekBarChangeListener);
        bSeekBar.setOnSeekBarChangeListener(onSeekBarChangeListener);
    }
}
