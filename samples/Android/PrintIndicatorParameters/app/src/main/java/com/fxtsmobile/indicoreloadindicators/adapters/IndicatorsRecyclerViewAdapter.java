package com.fxtsmobile.indicoreloadindicators.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.listeners.SelectListener;

import java.util.List;

public class IndicatorsRecyclerViewAdapter extends RecyclerView.Adapter<IndicatorsRecyclerViewAdapter.IndicatorsViewHolder> {

    private List<String> indicatorNames;
    private SelectListener indicatorSelectListener;

    public IndicatorsRecyclerViewAdapter(List<String> indicatorNames) {
        this.indicatorNames = indicatorNames;
    }

    @Override
    public IndicatorsViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_indicator, parent, false);
        return new IndicatorsViewHolder(view);
    }

    @Override
    public void onBindViewHolder(IndicatorsViewHolder holder, int position) {
        String name = indicatorNames.get(position);
        holder.getIndicatorNameTextView().setText(name);
        setupClick(holder);
    }

    public void setIndicatorSelectListener(SelectListener listener) {
        this.indicatorSelectListener = listener;
    }

    private void setupClick(final IndicatorsViewHolder holder) {
        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                int adapterPosition = holder.getAdapterPosition();

                if (indicatorSelectListener != null) {
                    indicatorSelectListener.onSelect(adapterPosition);
                }
            }
        });
    }

    @Override
    public int getItemCount() {
        return indicatorNames.size();
    }

    class IndicatorsViewHolder extends RecyclerView.ViewHolder {

        private TextView indicatorNameTextView;

        IndicatorsViewHolder(View itemView) {
            super(itemView);
            indicatorNameTextView = itemView.findViewById(R.id.indicatorNameTextView);
        }

        TextView getIndicatorNameTextView() {
            return indicatorNameTextView;
        }
    }

}
