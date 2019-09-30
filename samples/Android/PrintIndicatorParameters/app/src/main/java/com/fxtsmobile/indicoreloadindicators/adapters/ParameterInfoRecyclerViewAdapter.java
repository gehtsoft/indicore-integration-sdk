package com.fxtsmobile.indicoreloadindicators.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.listeners.SelectListener;
import com.fxtsmobile.indicoreloadindicators.model.ParameterDataInfo;
import com.fxtsmobile.indicoreloadindicators.model.ParameterHeaderInfo;
import com.fxtsmobile.indicoreloadindicators.model.ParameterInfo;

import java.util.List;

public class ParameterInfoRecyclerViewAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private List<ParameterInfo> parameterInfoList;
    private SelectListener parameterSelectListener;

    public ParameterInfoRecyclerViewAdapter(List<ParameterInfo> parameterInfoList) {

        this.parameterInfoList = parameterInfoList;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        if (viewType == ParameterInfo.TYPE_HEADER) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_parameter_info_header, parent, false);
            return new ParameterHeaderInfoViewHolder(view);
        }

        if (viewType == ParameterInfo.TYPE_DATA) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_parameter_info_data, parent, false);
            return new ParameterDataInfoViewHolder(view);
        }

        return null;
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, int position) {

        if (holder instanceof ParameterHeaderInfoViewHolder) {
            ParameterHeaderInfo parameterHeaderInfo = (ParameterHeaderInfo)parameterInfoList.get(position);
            ParameterHeaderInfoViewHolder parameterHeaderInfoViewHolder = (ParameterHeaderInfoViewHolder)holder;
            parameterHeaderInfoViewHolder.nameTextView.setText(parameterHeaderInfo.getName());
        }

        if (holder instanceof ParameterDataInfoViewHolder) {
            ParameterDataInfo parameterDataInfo = (ParameterDataInfo)parameterInfoList.get(position);
            ParameterDataInfoViewHolder parameterDataInfoViewHolder = (ParameterDataInfoViewHolder)holder;

            parameterDataInfoViewHolder.valueDescriptionTextView.setText(parameterDataInfo.getValueDescription());

            int alternativesVisibility = parameterDataInfo.getAlternatives().isEmpty()
                    ? View.GONE
                    : View.VISIBLE;

            parameterDataInfoViewHolder.alternativesLayout.setVisibility(alternativesVisibility);

            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {

                    int adapterPosition = holder.getAdapterPosition();

                    if (parameterSelectListener != null) {
                        parameterSelectListener.onSelect(adapterPosition);
                    }
                }
            });
        }
    }

    @Override
    public int getItemViewType(int position) {
        ParameterInfo parameterInfo = parameterInfoList.get(position);
        return parameterInfo.getType();
    }

    @Override
    public int getItemCount() {
        return parameterInfoList.size();
    }

    public void setParameterSelectListener(SelectListener listener) {
        this.parameterSelectListener = listener;
    }

    class ParameterHeaderInfoViewHolder extends RecyclerView.ViewHolder {

        TextView nameTextView;

        public ParameterHeaderInfoViewHolder(View itemView) {
            super(itemView);

            nameTextView = itemView.findViewById(R.id.nameTextView);
        }


    }

    class ParameterDataInfoViewHolder extends RecyclerView.ViewHolder {

        TextView valueDescriptionTextView;
        ViewGroup alternativesLayout;

        public ParameterDataInfoViewHolder(View itemView) {
            super(itemView);
            valueDescriptionTextView = itemView.findViewById(R.id.valueDescriptionTextView);
            alternativesLayout = itemView.findViewById(R.id.alternativesLayout);
        }
    }
}
