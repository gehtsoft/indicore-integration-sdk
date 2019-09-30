package com.fxtsmobile.indicoreloadindicators.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.RadioButton;

import com.fxtsmobile.indicoreloadindicators.R;

public class BoolEditDialogFragment extends ParameterEditDialogFragment<Boolean> {

    private RadioButton trueRadioButton;
    private RadioButton falseRadioButton;

    public static BoolEditDialogFragment newInstance() {
        return new BoolEditDialogFragment();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_dialog_bool_edit, container, false);

        parameterNameTextView = view.findViewById(R.id.parameterNameTextView);
        confirmButton = view.findViewById(R.id.okButton);
        trueRadioButton = view.findViewById(R.id.trueRadioButton);
        falseRadioButton = view.findViewById(R.id.falseRadioButton);

        return view;
    }

    @Override
    Boolean getInitialValue() {
        return parameter.value().getBoolean();
    }

    @Override
    protected void setup() {
        super.setup();

        if (getInitialValue()) {
            trueRadioButton.setChecked(true);
        } else {
            falseRadioButton.setChecked(true);
        }

        trueRadioButton.setOnCheckedChangeListener(checkedChangeListener);
        falseRadioButton.setOnCheckedChangeListener(checkedChangeListener);
    }

    private CompoundButton.OnCheckedChangeListener checkedChangeListener = new CompoundButton.OnCheckedChangeListener() {
        @Override
        public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
            if (!b) {
                return;
            }

            editValue = compoundButton.getId() == trueRadioButton.getId();
        }
    };
}
