package com.fxtsmobile.indicoreloadindicators.fragments;

import com.gehtsoft.indicore3.Parameter;
import com.gehtsoft.indicore3.ParameterAlternatives;
import com.gehtsoft.indicore3.ParameterConstant;

public class ParameterEditFragmentFactory {

    public static ParameterEditDialogFragment getEditFragment(Parameter parameter) {
        ParameterConstant.Type type = parameter.value().getType();

        ParameterAlternatives alternatives = parameter.getAlternatives();

        if (alternatives != null && alternatives.size() > 0) {
            return AlternativesEditDialogFragment.newInstance();
        } else {
            switch (type) {
                case Boolean:
                    return BoolEditDialogFragment.newInstance();
                case Integer:
                    return DigitsEditDialogFragment.<Integer>newInstance();
                case Double:
                    return DigitsEditDialogFragment.<Double>newInstance();
                case Color:
                    return ColorEditDialogFragment.newInstance();
                case File:
                case String:
                    return StringEditDialogFragment.newInstance();
                case Date:
                    return DateEditDialogFragment.newInstance();
            }
        }

        return null;
    }

}
