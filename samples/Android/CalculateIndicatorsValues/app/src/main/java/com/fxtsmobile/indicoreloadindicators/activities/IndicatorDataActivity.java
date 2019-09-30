package com.fxtsmobile.indicoreloadindicators.activities;

import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.adapters.IndicatorsDataPagerAdapter;

public class IndicatorDataActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_indicators_data);

        TabLayout tabLayout = findViewById(R.id.tabLayout);
        ViewPager indicatorsViewPager = findViewById(R.id.indicatorsDataPager);
        IndicatorsDataPagerAdapter adapter = new IndicatorsDataPagerAdapter(getSupportFragmentManager(), this);

        tabLayout.setupWithViewPager(indicatorsViewPager);
        indicatorsViewPager.setAdapter(adapter);
    }
}
