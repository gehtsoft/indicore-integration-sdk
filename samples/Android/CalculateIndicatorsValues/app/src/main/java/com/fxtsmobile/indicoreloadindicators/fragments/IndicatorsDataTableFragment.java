package com.fxtsmobile.indicoreloadindicators.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.adapters.IndicatorsTableRecyclerViewAdapter;
import com.fxtsmobile.indicoreloadindicators.core.SharedObjects;
import com.fxtsmobile.indicoreloadindicators.model.CandleChartItem;
import com.fxtsmobile.indicoreloadindicators.model.IndicatorChartConfiguration;
import com.fxtsmobile.indicoreloadindicators.model.IndicatorChartItem;

import java.util.List;

public class IndicatorsDataTableFragment extends Fragment {

    public static IndicatorsDataTableFragment newInstance() {
        return new IndicatorsDataTableFragment();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_indicator_data_table, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        TextView noDataTextView = view.findViewById(R.id.noDataTextView);
        RecyclerView tableRecyclerView = view.findViewById(R.id.tableRecyclerView);
        tableRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

        List<IndicatorChartConfiguration> indicatorChartConfigurations = SharedObjects.getInstance().getIndicatorData().getIndicatorChartConfigurations();
        List<IndicatorChartItem> indicatorChartItems = indicatorChartConfigurations.get(0).getIndicatorChartItems();

        if (indicatorChartConfigurations.isEmpty() || indicatorChartConfigurations.get(0).getIndicatorChartItems().isEmpty()) {
            noDataTextView.setVisibility(View.VISIBLE);
            tableRecyclerView.setVisibility(View.INVISIBLE);
        } else {
            IndicatorsTableRecyclerViewAdapter indicatorsTableRecyclerViewAdapter = new IndicatorsTableRecyclerViewAdapter(indicatorChartItems);
            tableRecyclerView.setAdapter(indicatorsTableRecyclerViewAdapter);
        }
    }
}
