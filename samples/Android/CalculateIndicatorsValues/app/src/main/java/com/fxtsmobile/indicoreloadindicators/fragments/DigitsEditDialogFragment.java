package com.fxtsmobile.indicoreloadindicators.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;

import com.fxtsmobile.indicoreloadindicators.R;
import com.gehtsoft.indicore3.ParameterConstant;

public class DigitsEditDialogFragment<T> extends ParameterEditDialogFragment<T> {

    private EditText parameterEditText;

    public static <T> DigitsEditDialogFragment<T> newInstance() {
        return new DigitsEditDialogFragment<>();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_dialog_digits_edit, container, false);

        parameterNameTextView = view.findViewById(R.id.parameterNameTextView);
        confirmButton = view.findViewById(R.id.okButton);
        parameterEditText = view.findViewById(R.id.parameterEditText);

        return view;
    }

    @Override
    protected void setup() {
        super.setup();

        String initialValueText = String.valueOf(getInitialValue());
        parameterEditText.setText(initialValueText);
        parameterEditText.setSelection(initialValueText.length());
    }

    @Override
    T getInitialValue() {
        ParameterConstant.Type type = parameter.getType();

        if (type == ParameterConstant.Type.Integer) {
            return (T)new Integer(parameter.value().getInteger());
        }
        if (type == ParameterConstant.Type.Double) {
            return (T)new Double(parameter.value().getDouble());
        }

        return null;
    }

    @Override
    protected void onEditCompleted() {
        editValue = getEditValue(parameterEditText.getText());
        super.onEditCompleted();
    }

    private T getEditValue(Editable editable) {
        String value = editable.toString();
        T newValue = editValue;

        try {
            ParameterConstant.Type type = parameter.getType();
            double aDouble = Double.valueOf(value);

            if (type == ParameterConstant.Type.Integer) {
                int i = (int)aDouble;
                newValue = (T)new Integer(i);
            }
            if (type == ParameterConstant.Type.Double) {
                newValue = (T)new Double(aDouble);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return newValue;
    }

}
