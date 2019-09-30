package com.fxtsmobile.indicoreloadindicators.activities;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.utils.DateUtil;
import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.adapters.ParameterInfoRecyclerViewAdapter;
import com.fxtsmobile.indicoreloadindicators.configuration.IndicatorSelectConfiguration;
import com.fxtsmobile.indicoreloadindicators.core.IndicatorType;
import com.fxtsmobile.indicoreloadindicators.core.SharedObjects;
import com.fxtsmobile.indicoreloadindicators.listeners.SelectListener;
import com.fxtsmobile.indicoreloadindicators.model.ParameterDataInfo;
import com.fxtsmobile.indicoreloadindicators.model.ParameterHeaderInfo;
import com.fxtsmobile.indicoreloadindicators.model.ParameterInfo;
import com.gehtsoft.indicore3.IndicatorProfile;
import com.gehtsoft.indicore3.IndicoreObject;
import com.gehtsoft.indicore3.Parameter;
import com.gehtsoft.indicore3.ParameterAlternative;
import com.gehtsoft.indicore3.ParameterAlternatives;
import com.gehtsoft.indicore3.ParameterConstant;
import com.gehtsoft.indicore3.ParameterGroup;
import com.gehtsoft.indicore3.ParameterGroups;
import com.gehtsoft.indicore3.ParameterValue;
import com.gehtsoft.indicore3.Parameters;

import java.util.ArrayList;
import java.util.List;

public class ParametersViewActivity extends AppCompatActivity {

    public static final String INDICATOR_SELECT_CONFIGURATION_KEY = "INDICATOR_SELECT_CONFIGURATION_KEY";
    private static final String DATE_FORMAT = "MM\\dd\\yyyy";

    private RecyclerView parametersRecyclerView;
    private TextView emptyTextView;

    private List<ParameterInfo> parameterInfos;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_parameters_view);
        IndicatorSelectConfiguration configuration = getIntent().getParcelableExtra(INDICATOR_SELECT_CONFIGURATION_KEY);

        parametersRecyclerView = findViewById(R.id.parametersRecyclerView);
        emptyTextView = findViewById(R.id.emptyTextView);

        final IndicatorProfile indicatorProfile = getIndicatorProfile(configuration);
        final String title = indicatorProfile.getName();

        Parameters parameters = indicatorProfile.getParameters();
        parameterInfos = getParameterInfos(parameters);

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                setTitle(title);
                setParameters();
            }
        });
    }

    private void setTitle(String title) {
        ActionBar supportActionBar = getSupportActionBar();

        if (supportActionBar != null) {
            supportActionBar.setTitle(title);
        }
    }

    private void setParameters() {
        if (parameterInfos.isEmpty()) {
            emptyTextView.setVisibility(View.VISIBLE);
            parametersRecyclerView.setVisibility(View.INVISIBLE);
        } else {
            ParameterInfoRecyclerViewAdapter adapter = new ParameterInfoRecyclerViewAdapter(parameterInfos);

            parametersRecyclerView.setLayoutManager(new LinearLayoutManager(this));
            parametersRecyclerView.setAdapter(adapter);

            adapter.setParameterSelectListener(parameterSelectListener);
        }
    }

    private SelectListener parameterSelectListener = new SelectListener() {
        @Override
        public void onSelect(int position) {
            ParameterInfo parameterInfo = parameterInfos.get(position);

            if (!(parameterInfo instanceof ParameterDataInfo)) {
                return;
            }

            ParameterDataInfo parameterDataInfo = (ParameterDataInfo)parameterInfo;

            if (parameterDataInfo.getAlternatives().isEmpty()) {
                return;
            }

            StringBuilder alternativesStringBuilder = new StringBuilder();

            for (String alternative : parameterDataInfo.getAlternatives()) {
                alternativesStringBuilder.append(alternative);
                alternativesStringBuilder.append("\n");
            }

            String alternativesTitle = getString(R.string.parameter_view_alternatives, parameterDataInfo.getName());
            String alternativesMessage = alternativesStringBuilder.toString();

            new AlertDialog.Builder(ParametersViewActivity.this)
                    .setTitle(alternativesTitle)
                    .setMessage(alternativesMessage)
                    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) { }
                    })
                    .create()
                    .show();
        }
    };

    private IndicatorProfile getIndicatorProfile(IndicatorSelectConfiguration configuration) {
        List<IndicatorProfile> indicatorProfiles = new ArrayList<>();

        if (configuration.getType() == IndicatorType.STANDARD) {
            indicatorProfiles = SharedObjects.getInstance().getStandardIndicatorProfiles();
        }
        if (configuration.getType() == IndicatorType.CUSTOM) {
            indicatorProfiles = SharedObjects.getInstance().getCustomIndicatorProfiles();
        }

        return indicatorProfiles.get(configuration.getPosition());
    }

    private List<ParameterInfo> getParameterInfos(Parameters parameters) {

        List<ParameterInfo> parameterInfos = new ArrayList<>();

        ParameterGroups groups = parameters.getGroups();

        for (ParameterGroup group : groups) {

            ParameterHeaderInfo parameterHeaderInfo = new ParameterHeaderInfo(group.getName());
            parameterInfos.add(parameterHeaderInfo);

            for (int pi = 0; pi < group.size(); pi++) {
                Parameter parameter = group.getParameter(pi);

                String name = parameter.getName();
                String valueDescription = getParameterValueDescription(parameter);

                ParameterAlternatives parameterAlternatives = parameter.getAlternatives();
                List<String> alternatives = getAlternatives(parameterAlternatives);

                ParameterDataInfo parameterDataInfo = new ParameterDataInfo(name, valueDescription, alternatives);
                parameterInfos.add(parameterDataInfo);
            }
        }

        return parameterInfos;
    }

    private List<String> getAlternatives(ParameterAlternatives parameterAlternatives) {
        List<String> alternatives = new ArrayList<>();

        if (parameterAlternatives != null) {
            for (ParameterAlternative a : parameterAlternatives) {
                String name = a.getName();
                alternatives.add(name);
            }
        }

        return alternatives;
    }

    private String getParameterValueDescription(Parameter parameter) {
        ParameterValue parameterValue = parameter.value();
        ParameterConstant.Type type = parameterValue.getType();
        String value = "";

        switch (type) {
            case Date: value = DateUtil.getDateString(parameter); break;
            case Color: value = getColorRgbValue(parameterValue.getColor()); break;
            case Double: value = Double.toString(parameterValue.getDouble()); break;
            case String: value = parameterValue.getString(); break;
            case Boolean: value = Boolean.toString(parameterValue.getBoolean()); break;
            case Integer: value = Integer.toString(parameterValue.getInteger()); break;
            case File: value = parameterValue.getFile(); break;
            case Null: value = ""; break;
            case Object: value = getObjectValue(parameterValue.getObject()); break;
        }

        if (value == null || value.isEmpty()) {
            value = "no value";
        }

        return parameter.getName() + " = " + value;
    }

    private String getObjectValue(IndicoreObject indicoreObject) {
        if (indicoreObject == null) {
            return "";
        }

        return indicoreObject.toString();
    }

    private String getColorRgbValue(int color) {
        int red = (color >> 16) & 255;
        int green = (color >> 8) & 255;
        int blue = color & 255;

        return "(" + red + ", " + green + ", " + blue + ")";
    }

}
