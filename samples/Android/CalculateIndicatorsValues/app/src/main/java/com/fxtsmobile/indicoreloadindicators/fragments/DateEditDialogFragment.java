package com.fxtsmobile.indicoreloadindicators.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.DatePicker;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.utils.DateUtil;

import java.util.Calendar;

public class DateEditDialogFragment extends ParameterEditDialogFragment<Calendar> {

    private DatePicker datePicker;
    private Calendar initialValue = null;
    private Calendar tempValue;

    public static DateEditDialogFragment newInstance() {
        return new DateEditDialogFragment();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_dialog_date_edit, container, false);

        parameterNameTextView = view.findViewById(R.id.parameterNameTextView);
        confirmButton = view.findViewById(R.id.okButton);
        datePicker = view.findViewById(R.id.datePicker);

        Calendar initialValue = getInitialValue();

        datePicker.init(initialValue.get(Calendar.YEAR), initialValue.get(Calendar.MONTH), initialValue.get(Calendar.DAY_OF_MONTH),
                new DatePicker.OnDateChangedListener() {
                    @Override
                    public void onDateChanged(DatePicker datePicker, int i, int i1, int i2) {
                        tempValue = Calendar.getInstance();
                        tempValue.set(i, i1, i2);
                    }
                });

        return view;
    }

    @Override
    protected void onEditCompleted() {
        editValue = tempValue;
        super.onEditCompleted();
    }

    @Override
    Calendar getInitialValue() {
        if (initialValue == null) {
            initialValue = DateUtil.getParameterCalendar(parameter);
            editValue = initialValue;
            tempValue = initialValue;
        }

        return initialValue;
    }
}
