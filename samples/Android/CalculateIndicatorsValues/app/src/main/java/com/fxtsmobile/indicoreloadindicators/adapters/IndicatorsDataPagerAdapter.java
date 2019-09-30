package com.fxtsmobile.indicoreloadindicators.adapters;

import android.content.Context;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.fragments.IndicatorsDataChartFragment;
import com.fxtsmobile.indicoreloadindicators.fragments.IndicatorsDataTableFragment;

public class IndicatorsDataPagerAdapter extends FragmentStatePagerAdapter {

    private static final int FRAGMENTS_COUNT = 2;

    private final Context context;

    public IndicatorsDataPagerAdapter(FragmentManager fm, Context context) {
        super(fm);
        this.context = context;
    }

    @Override
    public Fragment getItem(int position) {
        switch (position) {
            case 0:
                return IndicatorsDataTableFragment.newInstance();

            case 1:
                return IndicatorsDataChartFragment.newInstance();
        }

        throw new IllegalArgumentException("Fragment not found");
    }

    @Override
    public int getCount() {
        return FRAGMENTS_COUNT;
    }

    @Override
    public CharSequence getPageTitle(int position) {
        int titleId = 0;

        switch (position) {
            case 0:
                titleId = R.string.indicators_table;
                break;

            case 1:
                titleId = R.string.indicators_chart;
                break;
        }

        return titleId != 0
                ? context.getString(titleId)
                : "";
    }
}
