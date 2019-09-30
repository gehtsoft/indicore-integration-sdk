package com.fxtsmobile.indicoreloadindicators.activities;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.TextView;

import com.fxtsmobile.indicoreloadindicators.R;
import com.fxtsmobile.indicoreloadindicators.core.Core;
import com.fxtsmobile.indicoreloadindicators.core.Log;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView statusTextView = findViewById(R.id.statusTextView);

        Core.getInstance().setContext(getApplicationContext());
        statusTextView.setText("Copy assets");
        checkAssets();
        Core.getInstance().reload(statusTextView);

        Intent indicatorsViewIntent = new Intent(this, IndicatorsViewActivity.class);
        startActivity(indicatorsViewIntent);
        finish();
    }

    private void checkAssets() {
        checkAssets(Core.STANDARD_PATH);
        checkAssets(Core.CUSTOM_PATH);
        checkAssets("history");
    }

    private void checkAssets(String mask) {
        Log.getInstance().info("Extracting " + mask);

        File dirDist = new File(Core.getInstance().getDataDirectory().getPath() + "/" + mask);
        if (!dirDist.exists())
            dirDist.mkdirs();

        String[] list = null;
        try {
            list = getResources().getAssets().list(mask);
        } catch (IOException ex) {
            ex.printStackTrace();
            Log.getInstance().error("Extracting error: " + ex.getMessage());
            return;
        }

        for (String path : list) {
            String file = mask + "/" + path;
            Log.getInstance().debug("Extracting " + file);
            InputStream inFile;
            try {
                inFile = getResources().getAssets().open(file);
            } catch (IOException ex) {
                ex.printStackTrace();
                Log.getInstance().error("Extracting error for " + file + ": " + ex.getMessage());
                continue;
            }
            copyToData(inFile, dirDist.getPath() + "/" + path);
        }

        Log.getInstance().info("Finish extracting " + mask);
    }

    private void copyToData(InputStream inFile, String dist) {
        byte[] buffer = new byte[2048];
        FileOutputStream outStream = null;
        BufferedOutputStream outFile = null;
        try {
            outStream = new FileOutputStream(dist);
            outFile = new BufferedOutputStream(outStream);
            int size;
            while ((size = inFile.read(buffer, 0, buffer.length)) != -1) {
                outFile.write(buffer, 0, size);
            }
        } catch (IOException ex) {
            Log.getInstance().error("Extracting error: " + ex.getMessage());
        } finally {

            try {
                if (outFile != null) {
                    outFile.flush();
                    outFile.close();
                }
                if (outStream != null)
                    outStream.close();
                inFile.close();
            } catch (IOException ex) {
                Log.getInstance().error("Extracting error: " + ex.getMessage());
            }
        }
    }


}
