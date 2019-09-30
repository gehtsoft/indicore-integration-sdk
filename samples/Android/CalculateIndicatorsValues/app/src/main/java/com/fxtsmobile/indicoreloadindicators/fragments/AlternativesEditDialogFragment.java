package com.fxtsmobile.indicoreloadindicators.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import com.fxtsmobile.indicoreloadindicators.R;
import com.gehtsoft.indicore3.ParameterAlternative;
import com.gehtsoft.indicore3.ParameterAlternatives;
import com.gehtsoft.indicore3.ParameterConstant;

public class AlternativesEditDialogFragment extends ParameterEditDialogFragment<Object> {

    private RadioGroup parameterValuesRadioGroup;

    private ParameterAlternative initialAlternative = null;
    private ParameterAlternative editAlternative = null;

    public static AlternativesEditDialogFragment newInstance() {
        return new AlternativesEditDialogFragment();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_dialog_alternatives_edit, container, false);

        parameterNameTextView = view.findViewById(R.id.parameterNameTextView);
        confirmButton = view.findViewById(R.id.okButton);
        parameterValuesRadioGroup = view.findViewById(R.id.parameterValuesRadioGroup);

        return view;
    }

    @Override
    protected void setup() {
        super.setup();

        for (ParameterAlternative parameterAlternative : parameter.getAlternatives()) {
            RadioButton radioButton = new RadioButton(getContext());
            radioButton.setText(parameterAlternative.getName());
            radioButton.setTag(parameterAlternative.getID());

            parameterValuesRadioGroup.addView(radioButton);
        }

        for (int i = 0; i < parameterValuesRadioGroup.getChildCount(); i++) {
            RadioButton child = (RadioButton)parameterValuesRadioGroup.getChildAt(i);

            if (child.getTag().equals(getInitialValue().getID())) {
                child.setChecked(true);
            }
        }
    }

    @Override
    protected void onEditCompleted() {
        String checkedId = "";

        for (int i = 0; i < parameterValuesRadioGroup.getChildCount(); i++) {
            RadioButton child = (RadioButton)parameterValuesRadioGroup.getChildAt(i);

            if (child.isChecked()) {
                checkedId = (String)child.getTag();
                break;
            }
        }

        for (ParameterAlternative parameterAlternative : parameter.getAlternatives()) {
            if (parameterAlternative.getID().equals(checkedId)) {
                editAlternative = parameterAlternative;
                editValue = getParameterAlternativeValue(editAlternative);
                break;
            }
        }

        super.onEditCompleted();
    }

    @Override
    protected boolean isValueChanged() {
        return !editAlternative.getID().equals(getInitialValue().getID());
    }

    @Override
    ParameterAlternative getInitialValue() {
        if (initialAlternative == null) {
            ParameterAlternatives alternatives = parameter.getAlternatives();

            for (ParameterAlternative alternative : alternatives) {
                int i = alternative.value().compareTo(parameter.valueConst());
                if (i == 0) {
                    initialAlternative = alternative;
                    break;
                }
            }

            if (initialAlternative == null) {
                initialAlternative = alternatives.getAlternative(0);
            }
        }

        return initialAlternative;
    }

    private Object getParameterAlternativeValue(ParameterAlternative parameterAlternative) {
        ParameterConstant value = parameterAlternative.value();
        ParameterConstant.Type type = value.getType();

        switch (type) {
            case Boolean: return value.getBoolean();
            case Color:
            case Integer: return value.getInteger();
            case Double: return value.getDouble();
            case File:
            case String: return value.getString();
            case Date: return value.getDate();
            default: return null;
        }
    }

}
