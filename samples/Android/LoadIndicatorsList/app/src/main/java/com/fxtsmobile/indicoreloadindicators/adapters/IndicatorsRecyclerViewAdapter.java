package com.fxtsmobile.indicoreloadindicators.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.core.IndicatorInfo;

import java.util.List;

public class IndicatorsRecyclerViewAdapter extends RecyclerView.Adapter<IndicatorsRecyclerViewAdapter.IndicatorsViewHolder> {

    private List<IndicatorInfo> indicatorsInfo;

    public IndicatorsRecyclerViewAdapter(List<IndicatorInfo> indicatorsInfo) {
        this.indicatorsInfo = indicatorsInfo;
    }

    @Override
    public IndicatorsViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_indicator, parent, false);
        return new IndicatorsViewHolder(view);
    }

    @Override
    public void onBindViewHolder(IndicatorsViewHolder holder, int position) {
        IndicatorInfo indicatorInfo = indicatorsInfo.get(position);
        holder.setIndicatorInfo(indicatorInfo);
    }

    @Override
    public int getItemCount() {
        return indicatorsInfo.size();
    }

    class IndicatorsViewHolder extends RecyclerView.ViewHolder {

        private TextView indicatorNameTextView;
        private TextView indicatorNameTextViewDetail;

        IndicatorsViewHolder(View itemView) {
            super(itemView);
            indicatorNameTextView = itemView.findViewById(R.id.indicatorNameTextView);
            indicatorNameTextViewDetail = itemView.findViewById(R.id.indicatorNameTextViewDetail);
        }

        void setIndicatorInfo(IndicatorInfo indicatorInfo) {
            indicatorNameTextView.setText(indicatorInfo.getIndicatorName() + " (" + indicatorInfo.getIndicatorID() + ")");
            indicatorNameTextViewDetail.setText("Type: " + indicatorInfo.getIndicatorType() + ", required source: " + indicatorInfo.getRequiredSource());
        }
    }
}
