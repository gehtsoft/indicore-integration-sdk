package com.fxtsmobile.indicoreloadindicators.core;

import android.content.Context;
import android.widget.TextView;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;
import java.util.Vector;

import com.fxtsmobile.indicoreloadindicators.model.BarItem;
import com.fxtsmobile.indicoreloadindicators.model.CandleChartItem;
import com.fxtsmobile.indicoreloadindicators.model.IndicatorChartConfiguration;
import com.fxtsmobile.indicoreloadindicators.model.IndicatorChartItem;
import com.fxtsmobile.indicoreloadindicators.model.IndicatorData;
import com.gehtsoft.indicore3.BarPriceStorage;
import com.gehtsoft.indicore3.Domain;
import com.gehtsoft.indicore3.FileEnumerator;
import com.gehtsoft.indicore3.FileSystemAccessor;
import com.gehtsoft.indicore3.FileSystemMetadataProviderDefault;
import com.gehtsoft.indicore3.IndicatorInstance;
import com.gehtsoft.indicore3.IndicatorProfile;
import com.gehtsoft.indicore3.IndicatorProfiles;
import com.gehtsoft.indicore3.IndicoreException;
import com.gehtsoft.indicore3.IndicoreManager;
import com.gehtsoft.indicore3.LoadErrorList;
import com.gehtsoft.indicore3.LoadMetadataDefault;
import com.gehtsoft.indicore3.OutputStream;
import com.gehtsoft.indicore3.OutputStreamsCollection;
import com.gehtsoft.indicore3.Parameters;
import com.gehtsoft.indicore3.PriceStream;
import com.gehtsoft.indicore3.Profile;

public class Core {
	private static final String CSV_TICKS = "ticks.csv";
	private static final String CSV_BAR = "bars.csv";

	public static final String PATH_STANDARD = "indicators/standard";
	public static final String PATH_CUSTOM = "indicators/custom";
	public static final String PATH_HISTORY = "history";

	private static Core mInstance = null;
	public static Core getInstance() {
		return mInstance;
	}

	static {
		System.loadLibrary("indicore3.jni");
        mInstance = new Core();
	}

	private Core() {
        mManager = IndicoreManager.createInstance();
        mHost = new HostTest();
    }

	private IndicoreManager mManager;
	private HostTest mHost;
	private Context mContext;
	private String mLastError;

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

    public String getLastError() { return mLastError;
	}

	public void reload(TextView status) {

		Domain d = mManager.createDomain("main", "main");

		String dataPath = getDataDirectory().getPath() + "/";

		loadFolder(d, dataPath + PATH_STANDARD, Profile.ObjectType.Indicator, status,
				IndicatorType.STANDARD);

		loadFolder(d, dataPath + PATH_CUSTOM, Profile.ObjectType.Indicator, status,
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
				List<IndicatorProfile> indicators = new ArrayList<>();

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
		    mLastError = "Loading " + path + " failed:" + e.getMessage();
			Log.getInstance().warn(mLastError);
			return false;
		}
		Log.getInstance().info("Loading " + path + " success end");
		return true;
	}

	private long mElapsetUpdateTime = 0;
	private Vector<Vector<String>> mOutputs = null;

	public boolean run(IndicatorProfile profile, Parameters parameters) {
		PriceStream priceStream = null;
		BarPriceStorage priceStorage = null;

		String dataPath = getDataDirectory().getPath() + "/" + PATH_HISTORY + "/";


		IndicatorProfile.RequiredSource requiredSource = profile.getRequiredSource();

		if (profile.getRequiredSource() == IndicatorProfile.RequiredSource.Tick) {
			priceStorage = load(dataPath + CSV_TICKS);
		} else {
			priceStorage = load(dataPath + CSV_BAR);
		}

		if (priceStorage == null)
			return false;

		priceStream = priceStorage.getAskPrices();

		if (priceStream == null)
			return false;

		IndicatorInstance instance;
		try {
			instance = profile.createInstance(mHost, priceStream, parameters);
		} catch (IndicoreException e) {
		    mLastError = "Failed create isntance " + e.getMessage();
			Log.getInstance().error(mLastError);
			return false;
		}

		try {
			if (!instance.prepare(false)) {
			    mLastError = "Couldn't prepare indicator " + profile.getID();
				Log.getInstance().error(mLastError);
				return false;
			}
		} catch (IllegalStateException e) {
		    mLastError = "Failed prepare " + e.getMessage();
			Log.getInstance().error(mLastError);
			return false;
		} catch (IndicoreException e) {
			mLastError = "Failed prepare " + e.getMessage();
		    Log.getInstance().error(mLastError);
			return false;
		}

		long startTime = System.currentTimeMillis();
		try {
			instance.updateAll();
		} catch (IllegalStateException e) {
		    mLastError = "Failed updateAll " + e.getMessage();
			Log.getInstance().error(mLastError);
			return false;
		} catch (IndicoreException e) {
		    mLastError = "Failed updateAll " + e.getMessage();
			Log.getInstance().error(mLastError);
			return false;
		}
		long stopTime = System.currentTimeMillis();
		mElapsetUpdateTime = stopTime - startTime;

		Log.getInstance().info("Instance update time = " + mElapsetUpdateTime);

		if (instance.getStreams().size() == 0) {
			return false;
		}

		List<CandleChartItem> candleChartItems = new ArrayList<>();

		for (int i = 0; i < priceStorage.size(); i++) {
			Calendar date = priceStorage.date(i);

			double bidLow = priceStorage.getBidLow(i);
			double bidClose = priceStorage.getBidClose(i);
			double bidOpen = priceStorage.getBidOpen(i);
			double bidHigh = priceStorage.getBidHigh(i);

			BarItem barItem = new BarItem(bidLow, bidClose, bidOpen, bidHigh);

			candleChartItems.add(new CandleChartItem(barItem, date));
		}

		OutputStreamsCollection outputStreamsCollection = instance.getStreams();

		List<IndicatorChartConfiguration> indicatorChartConfigurations = new ArrayList<>();

		for (OutputStream outputStream : outputStreamsCollection) {
			List<IndicatorChartItem> indicatorChartItems = new ArrayList<>();

			for (int i = 0; i < outputStream.size(); i++) {
				double price = outputStream.getPrice(i);
				Calendar date = outputStream.date(i);

				indicatorChartItems.add(new IndicatorChartItem(price, date));
			}

			int color = outputStream.getColor();
			OutputStream.LineStyle lineStyle = outputStream.getLineStyle();
			int lineWidth = outputStream.getLineWidth();

			indicatorChartConfigurations.add(new IndicatorChartConfiguration(indicatorChartItems, color, lineWidth, lineStyle));
		}

		IndicatorData indicatorData = new IndicatorData();
		indicatorData.setIndicatorRequiredSource(profile.getRequiredSource());
		indicatorData.setIndicatorChartConfigurations(indicatorChartConfigurations);
		indicatorData.setCandleChartItems(candleChartItems);


		SharedObjects.getInstance().setIndicatorData(indicatorData);

		return true;
	}

	private BarPriceStorage load(String path) {
		File f = new File(path);
		BufferedReader br;
		try {
			br = new BufferedReader(new FileReader(f));
		} catch (FileNotFoundException e) {
		    mLastError = "Failed load tick history " + e.getMessage();
			Log.getInstance().error(mLastError);
			return null;
		}
		String line;
		BarPriceStorage result = null;
		try {
			SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
			sdf.setTimeZone(TimeZone.getTimeZone("EST"));
			while ((line = br.readLine()) != null) {
				String[] parts = line.split(";");
				if (parts[0].equals("HDR")) {
					double pipSize = Double.parseDouble(parts[6]);
					int precision = (int) Math.floor((-Math.log10(pipSize / 10.0)) + 0.5);
					result = new BarPriceStorage(parts[1], parts[1], parts[4], BarPriceStorage.OpenPriceMode.FirstTickNewBar, -7, 0,
							precision, precision, pipSize, parts[5].equals("1"), false, 0, 10000, 0);
				} else if (parts[0].equals("DAT")) {
					Calendar c = Calendar.getInstance();
					try {
					    c.setTimeZone(TimeZone.getTimeZone("EST"));
						c.setTime(sdf.parse(parts[1]));
					} catch (ParseException e) {
					    mLastError = "Failed load tick history " + e.getMessage();
						Log.getInstance().error(mLastError);
						continue;
					}
					result.addBar(c, Double.parseDouble(parts[2]), Double.parseDouble(parts[3]),
							Double.parseDouble(parts[4]), Double.parseDouble(parts[5]), Double.parseDouble(parts[6]),
							Double.parseDouble(parts[7]), Double.parseDouble(parts[8]), Double.parseDouble(parts[9]),
							parts.length > 10 ? Double.parseDouble(parts[10]) : 0);
				}
			}
			br.close();
			return result;
		} catch (IOException e) {
			try {
				br.close();
			} catch (IOException e1) {
			}
			mLastError = "Failed load tick history " + e.getMessage();
			Log.getInstance().error(mLastError);
			return null;
		}
	}
}
