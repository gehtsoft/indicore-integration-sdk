package com.fxtsmobile.indicoreloadindicators.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.FragmentManager;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.listeners.ParameterEditListener;
import com.gehtsoft.indicore3.Parameter;

public abstract class ParameterEditDialogFragment<T> extends DialogFragment {

    protected T editValue;
    protected Parameter parameter;
    protected ParameterEditListener<T> parameterEditListener;

    protected TextView parameterNameTextView;
    protected Button confirmButton;

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setup();
    }

    protected void onEditCompleted() {
        if (isValueChanged() && parameterEditListener != null) {
            parameterEditListener.onEditCompleted(editValue);
        }

        dismiss();
    }

    protected boolean isValueChanged() {
        return editValue != null && editValue != getInitialValue();
    }

    abstract T getInitialValue();

    protected void setup() {

        if (parameterNameTextView != null) {
            parameterNameTextView.setText(parameter.getName());
        }

        if (confirmButton != null) {
            confirmButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onEditCompleted();
                }
            });
        }
    }

    public void show(FragmentManager manager, Parameter parameter, ParameterEditListener<T> parameterEditListener) {
        this.parameter = parameter;
        this.parameterEditListener = parameterEditListener;
        super.show(manager, this.getClass().getSimpleName());
    }

    @Override
    public void onStart() {
        super.onStart();
        getDialog().getWindow().setLayout(ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    }
}
