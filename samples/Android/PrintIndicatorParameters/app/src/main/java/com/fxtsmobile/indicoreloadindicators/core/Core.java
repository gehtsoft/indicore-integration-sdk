package com.fxtsmobile.indicoreloadindicators.core;

import android.content.Context;
import android.widget.TextView;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import com.gehtsoft.indicore3.Domain;
import com.gehtsoft.indicore3.FileEnumerator;
import com.gehtsoft.indicore3.FileSystemAccessor;
import com.gehtsoft.indicore3.FileSystemMetadataProviderDefault;
import com.gehtsoft.indicore3.IndicatorProfile;
import com.gehtsoft.indicore3.IndicatorProfiles;
import com.gehtsoft.indicore3.IndicoreException;
import com.gehtsoft.indicore3.IndicoreManager;
import com.gehtsoft.indicore3.LoadErrorList;
import com.gehtsoft.indicore3.LoadMetadataDefault;
import com.gehtsoft.indicore3.Profile;

public class Core {
	public static final String STANDARD_PATH = "indicators/standard";
	public static final String CUSTOM_PATH = "indicators/custom";

	private static Core mInstance = null;
	public static Core getInstance() {
		return mInstance;
	}

	static {
		System.loadLibrary("indicore3.jni");
		mInstance = new Core();
	}

	public IndicoreManager mManager;
	private HostTest mHost;
	private Context mContext;


	private Core() {
        mManager = IndicoreManager.createInstance();
        mHost = new HostTest();
    }

	public IndicoreManager getManager() {
		return mManager;
	}

	public void setContext(Context c) {
		mContext = c;
	}

	public File getDataDirectory()
    {
    	return mContext.getFilesDir();
    }

	public void reload(TextView status) {

		Domain d = mManager.createDomain("main", "main");

		String dataPath = getDataDirectory().getPath() + "/";

		loadFolder(d, dataPath + STANDARD_PATH, Profile.ObjectType.Indicator, status,
				IndicatorType.STANDARD);

		loadFolder(d, dataPath + CUSTOM_PATH, Profile.ObjectType.Indicator, status,
				IndicatorType.CUSTOM);

	}

	private boolean loadFolder(Domain domain, String path, Profile.ObjectType type, TextView status, int indicatorType) {
		status.setText(path);
		Log.getInstance().info("Loading " + path + " started");
		FileSystemAccessor fsa = new FileSystemAccessor();
		FileSystemMetadataProviderDefault pd = new FileSystemMetadataProviderDefault(Profile.Language.Lua, type);

		try {
			fsa.init(path, pd);
			FileEnumerator enumerator = fsa.enumerator(new String[] { "*.lua" }, false);
			LoadErrorList ex = mManager.loadIntoDomain(domain, fsa, enumerator, new LoadMetadataDefault(mHost));
			if (ex != null) {
				for (int i = 0; i < ex.size(); ++i)
					Log.getInstance().info(ex.getError(i).getText());
			}

			if (type == Profile.ObjectType.Indicator) {
				IndicatorProfiles ps = mManager.getIndicatorProfiles();
				List<IndicatorProfile> indicators = new ArrayList<IndicatorProfile>();

				for (IndicatorProfile p : ps) {
					indicators.add(p);
					Log.getInstance().debug("Loaded " + p.getID() + " indicator");
				}


				if (indicatorType == IndicatorType.STANDARD) {
					SharedObjects.getInstance().setStandardIndicatorProfiles(indicators);
				}
				if (indicatorType == IndicatorType.CUSTOM) {
					indicators.removeAll(SharedObjects.getInstance().getStandardIndicatorProfiles());
					SharedObjects.getInstance().setCustomIndicatorProfiles(indicators);
				}
			}
		} catch (IndicoreException e) {
			Log.getInstance().warn("Loading " + path + " failed:" + e.getMessage());
			return false;
		}
		Log.getInstance().info("Loading " + path + " success end");
		return true;
	}

}
