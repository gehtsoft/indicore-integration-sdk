package com.fxtsmobile.indicoreloadindicators.Dialogs;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Build;

import com.fxtsmobile.indicoreloadindicators.core.Core;

public class ErrorDialog {

    private Context mCtx;
    private String mErrorMsg;
    private AlertDialog.Builder mDialogBuilder;

    public ErrorDialog(String errorMsg, Context ctx) {
        mErrorMsg = errorMsg;
        mCtx = ctx;
        createDialog();
    }

    public void show() {
        mDialogBuilder.show();
    }

    private void createDialog() {
        String error = Core.getInstance().getLastError();

        AlertDialog.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            builder = new AlertDialog.Builder(mCtx, android.R.style.Theme_Material_Dialog_Alert);
        } else {
            builder = new AlertDialog.Builder(mCtx);
        }
        mDialogBuilder = builder.setTitle("Error")
                            .setMessage(mErrorMsg)
                            .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {
                                    // do nothing
                                }
                            })
                            .setIcon(android.R.drawable.ic_dialog_alert);
    }
}
