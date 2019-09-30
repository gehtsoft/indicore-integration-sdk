package com.fxtsmobile.indicoreloadindicators.fragments;

import android.graphics.Color;
import android.graphics.Paint;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.core.SharedObjects;
import com.fxtsmobile.indicoreloadindicators.model.BarItem;
import com.fxtsmobile.indicoreloadindicators.model.CandleChartItem;
import com.fxtsmobile.indicoreloadindicators.model.IndicatorChartConfiguration;
import com.fxtsmobile.indicoreloadindicators.model.IndicatorChartItem;
import com.fxtsmobile.indicoreloadindicators.model.RgbColor;
import com.fxtsmobile.indicoreloadindicators.utils.ColorUtil;
import com.gehtsoft.indicore3.IndicatorProfile;
import com.github.mikephil.charting.charts.CombinedChart;
import com.github.mikephil.charting.components.AxisBase;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.data.CandleData;
import com.github.mikephil.charting.data.CandleDataSet;
import com.github.mikephil.charting.data.CandleEntry;
import com.github.mikephil.charting.data.CombinedData;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.formatter.IAxisValueFormatter;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

public class IndicatorsDataChartFragment extends Fragment {
    private static final String DATE_TIME_FORMAT = "HH:mm";

    private CombinedChart combinedChart;

    public static IndicatorsDataChartFragment newInstance() {
        return new IndicatorsDataChartFragment();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_indicator_data_chart, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        combinedChart = view.findViewById(R.id.combinedChart);

        IndicatorProfile.RequiredSource indicatorRequiredSource = SharedObjects.getInstance().getIndicatorData().getIndicatorRequiredSource();

        if (indicatorRequiredSource == IndicatorProfile.RequiredSource.Tick) {
            buildTickSourceChart(getCloseLinearDataSet());
        } else {
            buildBarSourceChart(getCandleEntries(), "");
        }
    }

    private void buildTickSourceChart(LineDataSet lineDataSet) {
        CombinedData combinedData = new CombinedData();
        LineData lineData = new LineData();

        lineData.addDataSet(lineDataSet);

        List<LineDataSet> indicatorChartDatas = getIndicatorChartData();

        for (LineDataSet indicatorChartData : indicatorChartDatas) {
            lineData.addDataSet(indicatorChartData);
        }

        combinedData.setData(lineData);
        combinedChart.getDescription().setEnabled(false);
        combinedChart.setData(combinedData);
        combinedChart.invalidate();

        XAxis xAxis = combinedChart.getXAxis();
        xAxis.setValueFormatter(axisXDateTimeValueFormatter);
    }

    private void buildBarSourceChart(List<CandleEntry> entries, String label) {
        if (entries.isEmpty()) {
            combinedChart.clear();
            return;
        }

        CombinedData combinedData = new CombinedData();

        CandleDataSet candleDataSet = getCandleDataSet(entries, label);
        CandleData candleData = new CandleData(candleDataSet);
        combinedData.setData(candleData);

        List<LineDataSet> indicatorChartDatas = getIndicatorChartData();

        LineData indicatorLineData = new LineData();

        for (LineDataSet indicatorChartData : indicatorChartDatas) {
            indicatorLineData.addDataSet(indicatorChartData);
        }

        combinedData.setData(indicatorLineData);

        combinedChart.getDescription().setEnabled(false);
        combinedChart.setData(combinedData);
        combinedChart.invalidate();

        XAxis xAxis = combinedChart.getXAxis();
        xAxis.setValueFormatter(axisXDateTimeValueFormatter);
    }

    private List<LineDataSet> getIndicatorChartData() {

        List<LineDataSet> lineDataSets = new ArrayList<>();

        List<IndicatorChartConfiguration> indicatorChartConfigurations = SharedObjects.getInstance().getIndicatorData().getIndicatorChartConfigurations();

        for (IndicatorChartConfiguration indicatorChartConfiguration : indicatorChartConfigurations) {
            List<IndicatorChartItem> indicatorChartItems = indicatorChartConfiguration.getIndicatorChartItems();

            List<Entry> entries = new ArrayList<>();

            for (int i = 0; i < indicatorChartItems.size(); i++) {

                float price = (float) indicatorChartItems.get(i).getPrice();

                if (price != 0) {
                    entries.add(new Entry(i, price));
                }
            }

            LineDataSet lineDataSet = new LineDataSet(entries, "");

            RgbColor rgb = ColorUtil.getRgb(indicatorChartConfiguration.getIndicatorColor());
            lineDataSet.setColor(ColorUtil.getColor(rgb));

            lineDataSet.setLineWidth(indicatorChartConfiguration.getLineWidth());

            lineDataSet.setDrawValues(false);
            lineDataSet.setDrawCircles(false);
            lineDataSets.add(lineDataSet);
        }

        return lineDataSets;
    }

    private LineDataSet getCloseLinearDataSet() {
        List<CandleChartItem> candleChartItems = SharedObjects.getInstance().getIndicatorData().getCandleChartItems();
        List<Entry> entries = new ArrayList<>();

        for (int i = 0; i < candleChartItems.size(); i++) {
            double close = candleChartItems.get(i).getBarItem().getClose();
            entries.add(new Entry(i, (float)close));
        }

        LineDataSet lineDataSet = new LineDataSet(entries, "");
        lineDataSet.setColor(Color.BLACK);

        return lineDataSet;
    }

    private CandleDataSet getCandleDataSet(List<CandleEntry> entries, String label) {
        CandleDataSet candleDataSet = new CandleDataSet(entries, label);
        candleDataSet.setColor(Color.BLACK);
        candleDataSet.setShadowColor(Color.DKGRAY);
        candleDataSet.setShadowWidth(1f);
        candleDataSet.setDecreasingColor(Color.RED);
        candleDataSet.setDecreasingPaintStyle(Paint.Style.FILL);
        candleDataSet.setIncreasingColor(Color.rgb(122, 242, 84));
        candleDataSet.setIncreasingPaintStyle(Paint.Style.FILL);
        candleDataSet.setNeutralColor(Color.BLUE);
        candleDataSet.setValueTextColor(Color.RED);
        candleDataSet.setDrawValues(false);

        return candleDataSet;
    }

    private List<CandleEntry> getCandleEntries() {
        List<CandleChartItem> chartData = SharedObjects.getInstance().getIndicatorData().getCandleChartItems();
        List<CandleEntry> entries = new ArrayList<>();

        for (int i = 0; i < chartData.size(); i++) {
            CandleChartItem candleChartItem = chartData.get(i);
            BarItem barItem = candleChartItem.getBarItem();
            CandleEntry candleEntry = new CandleEntry(i, (float)barItem.getHigh(), (float)barItem.getLow(), (float)barItem.getOpen(), (float)barItem.getClose());
            entries.add(candleEntry);
        }

        return entries;
    }

    private String getChartItemDate(Calendar calendar) {
        SimpleDateFormat timeFormat = new SimpleDateFormat(DATE_TIME_FORMAT, Locale.getDefault());
        return timeFormat.format(calendar.getTime());
    }

    private IAxisValueFormatter axisXDateTimeValueFormatter = new IAxisValueFormatter() {
        @Override
        public String getFormattedValue(float value, AxisBase axis) {
            int position = (int)value;
            List<CandleChartItem> chartData = SharedObjects.getInstance().getIndicatorData().getCandleChartItems();
            CandleChartItem candleChartItem = chartData.get(position);
            Calendar calendar = candleChartItem.getCalendar();
            return getChartItemDate(calendar);
        }
    };

    @Override
    public void onDestroyView() {
        combinedChart.clear();
        super.onDestroyView();
    }

}
