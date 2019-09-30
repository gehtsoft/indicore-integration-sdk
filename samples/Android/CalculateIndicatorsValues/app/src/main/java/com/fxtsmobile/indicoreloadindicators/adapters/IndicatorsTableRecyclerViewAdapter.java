package com.fxtsmobile.indicoreloadindicators.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.model.IndicatorChartItem;
import com.fxtsmobile.indicoreloadindicators.utils.DateUtil;

import java.util.List;

public class IndicatorsTableRecyclerViewAdapter extends RecyclerView.Adapter<IndicatorsTableRecyclerViewAdapter.IndicatorsTableViewHolder> {

    private List<IndicatorChartItem> data;

    public IndicatorsTableRecyclerViewAdapter(List<IndicatorChartItem> data) {

        this.data = data;
    }

    @Override
    public IndicatorsTableViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_indicator_table_item, parent, false);
        return new IndicatorsTableViewHolder(view);
    }

    @Override
    public void onBindViewHolder(IndicatorsTableViewHolder holder, int position) {
        IndicatorChartItem item = data.get(position);

        String date = DateUtil.getTableDateString(item.getCalendar());
        String price = String.valueOf(item.getPrice());

        holder.dateTextView.setText(date);
        holder.priceTextView.setText(price);

    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    class IndicatorsTableViewHolder extends RecyclerView.ViewHolder {

        TextView dateTextView;
        TextView priceTextView;

        public IndicatorsTableViewHolder(View itemView) {
            super(itemView);

            dateTextView = itemView.findViewById(R.id.dateTextView);
            priceTextView = itemView.findViewById(R.id.priceTextView);
        }


    }

}
