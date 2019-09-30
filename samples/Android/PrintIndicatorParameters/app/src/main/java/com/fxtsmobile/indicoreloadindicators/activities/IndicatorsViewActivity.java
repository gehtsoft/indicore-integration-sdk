package com.fxtsmobile.indicoreloadindicators.activities;

import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.adapters.IndicatorsViewPagerAdapter;

public class IndicatorsViewActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_indicators_view);

        TabLayout tabLayout = findViewById(R.id.tabLayout);
        ViewPager indicatorsViewPager = findViewById(R.id.indicatorsViewPager);
        IndicatorsViewPagerAdapter indicatorsViewPagerAdapter = new IndicatorsViewPagerAdapter(getSupportFragmentManager(), this);

        tabLayout.setupWithViewPager(indicatorsViewPager);
        indicatorsViewPager.setAdapter(indicatorsViewPagerAdapter);
    }
}
