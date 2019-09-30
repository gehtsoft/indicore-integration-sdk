package com.fxtsmobile.indicoreloadindicators.adapters;

import android.content.Context;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.core.IndicatorType;
import com.fxtsmobile.indicoreloadindicators.fragments.IndicatorsListFragment;

public class IndicatorsViewPagerAdapter extends FragmentStatePagerAdapter {
    private static final int FRAGMENTS_COUNT = 2;

    private Context context;

    public IndicatorsViewPagerAdapter(FragmentManager fm, Context context) {
        super(fm);
        this.context = context;
    }

    @Override
    public Fragment getItem(int position) {
        switch (position) {
            case 0:
                return IndicatorsListFragment.newInstance(IndicatorType.STANDARD);

            case 1:
                return IndicatorsListFragment.newInstance(IndicatorType.CUSTOM);
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
                titleId = R.string.indicators_standard;
                break;

            case 1:
                titleId = R.string.indicators_custom;
                break;
        }

        return titleId != 0
                ? context.getString(titleId)
                : "";
    }
}
