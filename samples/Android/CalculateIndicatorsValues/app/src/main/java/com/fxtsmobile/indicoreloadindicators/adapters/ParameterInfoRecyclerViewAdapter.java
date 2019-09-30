package com.fxtsmobile.indicoreloadindicators.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.listeners.SelectListener;
import com.fxtsmobile.indicoreloadindicators.model.ParameterColorDataInfo;
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

        switch (viewType) {
            case ParameterInfo.TYPE_HEADER: {
                View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_parameter_info_header, parent, false);
                return new ParameterHeaderInfoViewHolder(view);
            }
            case ParameterInfo.TYPE_DATA: {
                View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_parameter_info_data, parent, false);
                return new ParameterDataInfoViewHolder(view);
            }
            case ParameterInfo.TYPE_COLOR: {
                View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_parameter_info_data_color, parent, false);
                return new ParameterColorDataInfoViewHolder(view);
            }

            default:
                return null;
        }
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

            int alternativesVisibility = parameterDataInfo.hasAlternatives()
                    ? View.VISIBLE
                    : View.GONE;

            parameterDataInfoViewHolder.alternativesLayout.setVisibility(alternativesVisibility);
        }

        if (holder instanceof ParameterColorDataInfoViewHolder) {
            ParameterColorDataInfo parameterColorDataInfo = (ParameterColorDataInfo)parameterInfoList.get(position);
            ParameterColorDataInfoViewHolder parameterColorDataInfoViewHolder = (ParameterColorDataInfoViewHolder)holder;
            parameterColorDataInfoViewHolder.valueDescriptionTextView.setText(parameterColorDataInfo.getValueDescription());
            parameterColorDataInfoViewHolder.colorView.setBackgroundColor(parameterColorDataInfo.getColor());
        }

        if (!(holder instanceof ParameterHeaderInfoViewHolder)) {

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

        if (parameterInfo.getType() == ParameterInfo.TYPE_COLOR) {
            hashCode();
        }

        return parameterInfo.getType();
    }

    @Override
    public int getItemCount() {
        return parameterInfoList.size();
    }

    public void setParameterSelectListener(SelectListener listener) {
        this.parameterSelectListener = listener;
    }

    public void changeParameterDataInfo(ParameterDataInfo parameterDataInfo) {
        for (ParameterInfo parameterInfo : parameterInfoList) {
            if (!(parameterInfo instanceof ParameterDataInfo)) {
                continue;
            }

            if (((ParameterDataInfo)parameterInfo).getId().equals(parameterDataInfo.getId())) {
                int index = parameterInfoList.indexOf(parameterInfo);
                parameterInfoList.set(index, parameterDataInfo);
                notifyItemChanged(index);
                return;
            }
        }
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

    class ParameterColorDataInfoViewHolder extends RecyclerView.ViewHolder {

        TextView valueDescriptionTextView;
        View colorView;

        public ParameterColorDataInfoViewHolder(View itemView) {
            super(itemView);
            valueDescriptionTextView = itemView.findViewById(R.id.valueDescriptionTextView);
            colorView = itemView.findViewById(R.id.colorView);
        }
    }

}
