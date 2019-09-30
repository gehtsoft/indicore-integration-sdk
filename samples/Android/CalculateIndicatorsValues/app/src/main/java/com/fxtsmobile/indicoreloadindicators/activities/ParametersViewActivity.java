package com.fxtsmobile.indicoreloadindicators.activities;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.fxtsmobile.indicoreloadindicators.Dialogs.ErrorDialog;
import com.fxtsmobile.indicoreloadindicators.fragments.ParameterEditFragmentFactory;
import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.adapters.ParameterInfoRecyclerViewAdapter;
import com.fxtsmobile.indicoreloadindicators.configuration.IndicatorSelectConfiguration;
import com.fxtsmobile.indicoreloadindicators.core.Core;
import com.fxtsmobile.indicoreloadindicators.core.IndicatorType;
import com.fxtsmobile.indicoreloadindicators.core.SharedObjects;
import com.fxtsmobile.indicoreloadindicators.fragments.ParameterEditDialogFragment;
import com.fxtsmobile.indicoreloadindicators.listeners.ParameterEditListener;
import com.fxtsmobile.indicoreloadindicators.listeners.SelectListener;
import com.fxtsmobile.indicoreloadindicators.model.ParameterColorDataInfo;
import com.fxtsmobile.indicoreloadindicators.model.ParameterDataInfo;
import com.fxtsmobile.indicoreloadindicators.model.ParameterHeaderInfo;
import com.fxtsmobile.indicoreloadindicators.model.ParameterInfo;
import com.fxtsmobile.indicoreloadindicators.model.RgbColor;
import com.fxtsmobile.indicoreloadindicators.utils.ColorUtil;
import com.fxtsmobile.indicoreloadindicators.utils.DateUtil;
import com.gehtsoft.indicore3.IndicatorProfile;
import com.gehtsoft.indicore3.IndicoreObject;
import com.gehtsoft.indicore3.Parameter;
import com.gehtsoft.indicore3.ParameterAlternatives;
import com.gehtsoft.indicore3.ParameterConstant;
import com.gehtsoft.indicore3.ParameterGroup;
import com.gehtsoft.indicore3.ParameterGroups;
import com.gehtsoft.indicore3.ParameterValue;
import com.gehtsoft.indicore3.Parameters;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class ParametersViewActivity extends AppCompatActivity {

    public static final String INDICATOR_SELECT_CONFIGURATION_KEY = "INDICATOR_SELECT_CONFIGURATION_KEY";

    private IndicatorProfile indicatorProfile;
    private Parameters indicatorParameters;

    private RecyclerView parametersRecyclerView;
    private TextView emptyTextView;

    private ParameterInfoRecyclerViewAdapter adapter;

    private List<ParameterInfo> parameterInfos = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_parameters_view);
        IndicatorSelectConfiguration configuration = getIntent().getParcelableExtra(INDICATOR_SELECT_CONFIGURATION_KEY);

        parametersRecyclerView = findViewById(R.id.parametersRecyclerView);
        emptyTextView = findViewById(R.id.emptyTextView);

        indicatorProfile = getIndicatorProfile(configuration);
        indicatorParameters = indicatorProfile.getParameters();
        parameterInfos = getParameterInfos(indicatorParameters.getGroups());
        final String title = indicatorProfile.getName();

        // android.R.drawable.ic_menu_upload

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                setTitle(title);
                setParameters();
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_parameters_view, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.uploadMenu) {
            boolean calculatedSuccessfully =  Core.getInstance().run(indicatorProfile, indicatorParameters);
            if (calculatedSuccessfully) {
                startActivity(new Intent(this, IndicatorDataActivity.class));
            } else {
                ErrorDialog errDialog = new ErrorDialog(Core.getInstance().getLastError(),this);
                errDialog.show();
            }

            return calculatedSuccessfully;
        }

        return super.onOptionsItemSelected(item);
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
            adapter = new ParameterInfoRecyclerViewAdapter(parameterInfos);

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
            if (!parameterDataInfo.isEditable()) {
                return;
            }
            final String parameterId = parameterDataInfo.getId();
            Parameter parameter = indicatorParameters.getParameter(parameterId);

            ParameterEditDialogFragment editFragment = ParameterEditFragmentFactory.getEditFragment(parameter);

            if (editFragment == null) {
                onCannotEdit();
            } else {
                editFragment.show(getSupportFragmentManager(), parameter, new ParameterEditListener() {
                    @Override
                    public void onEditCompleted(Object value) {
                        onParameterEditCompleted(parameterId, value);
                    }
                });
            }
        }
    };

    private void setParameterValue(Parameter editParameter, Object newValue) {
        if (newValue == null) {
            return;
        }

        ParameterValue parameterValue = editParameter.value();

        if (newValue instanceof Integer) {
            parameterValue.setInteger((Integer) newValue);
        }
        if (newValue instanceof Double) {
            parameterValue.setDouble((Double) newValue);
        }
        if (newValue instanceof String) {
            parameterValue.setString((String) newValue);
        }
        if (newValue instanceof Boolean) {
            parameterValue.setBoolean((Boolean) newValue);
        }
        if (newValue instanceof Calendar) {
            DateUtil.setDate(parameterValue, (Calendar) newValue);
        }
    }
    private void onCannotEdit() {
        new AlertDialog.Builder(ParametersViewActivity.this)
                .setMessage("Can't edit this parameter")
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) { }
                })
                .create()
                .show();
    }

    private void onParameterEditCompleted(String parameterId, Object newValue) {
        Parameter parameter = indicatorParameters.getParameter(parameterId);
        setParameterValue(parameter, newValue);
        ParameterDataInfo parameterDataInfo = getParameterDataInfo(parameter);
        adapter.changeParameterDataInfo(parameterDataInfo);
    }

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

    private List<ParameterInfo> getParameterInfos(ParameterGroups groups) {

        List<ParameterInfo> parameterInfos = new ArrayList<>();

        for (ParameterGroup group : groups) {

            ParameterHeaderInfo parameterHeaderInfo = new ParameterHeaderInfo(group.getName());
            parameterInfos.add(parameterHeaderInfo);

            for (int pi = 0; pi < group.size(); pi++) {
                Parameter parameter = group.getParameter(pi);
                ParameterDataInfo parameterDataInfo = getParameterDataInfo(parameter);
                parameterInfos.add(parameterDataInfo);
            }
        }

        return parameterInfos;
    }

    private ParameterDataInfo getParameterDataInfo(Parameter parameter) {
        String id = parameter.getID();
        String valueDescription = getParameterValueDescription(parameter);

        ParameterAlternatives parameterAlternatives = parameter.getAlternatives();
        boolean hasAlternatives = parameterAlternatives != null && parameterAlternatives.size() > 0;

        if (parameter.value().getType() == ParameterConstant.Type.Color) {
            int parameterColor = parameter.value().getColor();
            RgbColor rgb = ColorUtil.getRgb(parameterColor);
            return new ParameterColorDataInfo(id, valueDescription, ColorUtil.getColor(rgb));
        } else {
            return new ParameterDataInfo(id, valueDescription, hasAlternatives);
        }
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
        RgbColor rgb = ColorUtil.getRgb(color);
        return "(" + rgb.getRed() + ", " + rgb.getGreen() + ", " + rgb.getBlue() + ")";
    }
}













