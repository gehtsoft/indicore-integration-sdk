package com.fxtsmobile.indicoreloadindicators.fragments;


import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.adapters.IndicatorsRecyclerViewAdapter;
import com.fxtsmobile.indicoreloadindicators.core.IndicatorInfo;
import com.fxtsmobile.indicoreloadindicators.core.IndicatorType;
import com.fxtsmobile.indicoreloadindicators.core.SharedObjects;
import com.gehtsoft.indicore3.IndicatorProfile;

import java.util.ArrayList;
import java.util.List;

public class IndicatorsListFragment extends Fragment {

    private static final String INDICATOR_TYPE_KEY = "INDICATOR_TYPE_KEY";
    private int indicatorType = 0;

    private RecyclerView indicatorsRecyclerView;
    private IndicatorsRecyclerViewAdapter indicatorsRecyclerViewAdapter;

    public static IndicatorsListFragment newInstance(int indicatorType) {
        Bundle args = new Bundle();
        args.putInt(INDICATOR_TYPE_KEY, indicatorType);

        IndicatorsListFragment fragment = new IndicatorsListFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        indicatorType = getArguments().getInt(INDICATOR_TYPE_KEY, 0);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_indicators_list, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        indicatorsRecyclerView = view.findViewById(R.id.indicatorsRecyclerView);
        setupIndicatorsList();
    }

    private void setupIndicatorsList() {
        List<IndicatorProfile> indicatorProfiles = getIndicatorProfiles();
        List<IndicatorInfo> indicatorsInfo = getIndicatorNamesList(indicatorProfiles);

        indicatorsRecyclerViewAdapter = new IndicatorsRecyclerViewAdapter(indicatorsInfo);

        indicatorsRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        indicatorsRecyclerView.setAdapter(indicatorsRecyclerViewAdapter);
    }

    private List<IndicatorProfile> getIndicatorProfiles() {
        List<IndicatorProfile> indicatorProfiles = new ArrayList<>();

        if (indicatorType == IndicatorType.STANDARD) {
            indicatorProfiles = SharedObjects.getInstance().getStandardIndicatorProfiles();
        }
        if (indicatorType == IndicatorType.CUSTOM) {
            indicatorProfiles = SharedObjects.getInstance().getCustomIndicatorProfiles();
        }

        return indicatorProfiles;
    }


    private List<IndicatorInfo> getIndicatorNamesList(List<IndicatorProfile> indicatorProfiles) {
        List<IndicatorInfo> indicatorsInfo = new ArrayList<>();

        for (IndicatorProfile profile : indicatorProfiles) {
            IndicatorInfo indicatorInfo = new IndicatorInfo(profile.getName(),
                    profile.getID(),
                    profile.getIndicatorType().toString(),
                    profile.getRequiredSource().toString());
            indicatorsInfo.add(indicatorInfo);
        }

        return indicatorsInfo;
    }
}
