package com.fxtsmobile.indicoreloadindicators.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;

import com.fxtsmobile.indicoreloadindicators.R;

public class StringEditDialogFragment extends ParameterEditDialogFragment<String> {

    private EditText parameterEditText;

    public static StringEditDialogFragment newInstance() {
        return new StringEditDialogFragment();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_dialog_string_edit, container, false);

        parameterNameTextView = view.findViewById(R.id.parameterNameTextView);
        confirmButton = view.findViewById(R.id.okButton);
        parameterEditText = view.findViewById(R.id.parameterEditText);

        return view;
    }

    @Override
    protected void setup() {
        super.setup();
        parameterEditText.setText(getInitialValue());
        parameterEditText.setSelection(getInitialValue().length());
    }

    @Override
    String getInitialValue() {
        return parameter.value().getString();
    }

    @Override
    protected void onEditCompleted() {
        editValue = parameterEditText.getText().toString();
        super.onEditCompleted();
    }
}
