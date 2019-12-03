package com.gehtsoft.indicore3.RunStrategy;

import com.gehtsoft.indicore3.*;
import com.gehtsoft.indicore3.RunStrategy.Host.SimpleHost;
import com.gehtsoft.indicore3.RunStrategy.SampleParams.SampleParams;
import com.gehtsoft.indicore3.RunStrategy.CsvTickDataParser.CsvTickDataParser;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class Main {

    private static final String PROG_NAME = "RunStrategy";
        private static String mIndicatorsPath;
        private static String mStrategiesPath;
        private static String mStrategyId;
        private static String mPriceDataPath;

    static {
        System.loadLibrary("indicore3_jni");
    }

    public static void main(String[] args) throws IndicoreException {
        try {
            Main.run(args);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void run(String[] args) throws Exception {

        boolean paramsAreValid = parseCmdParams(args);
        if (!paramsAreValid)
            return;

        //create file accessor for loading Lua indicators
        FileSystemAccessor indiFileAccessor =  new FileSystemAccessor();
        FileSystemMetadataProvider indiFSMetadataProvider = new FileSystemMetadataProviderDefault(Profile.Language.Lua,
                Profile.ObjectType.Indicator);
        indiFileAccessor.init(mIndicatorsPath, indiFSMetadataProvider);


        //create file accessor for loading Lua strategies
        FileSystemAccessor strategyFileAccessor =  new FileSystemAccessor();
        FileSystemMetadataProvider strategyFSMetadataProvider = new FileSystemMetadataProviderDefault(Profile.Language.Lua,
                Profile.ObjectType.Strategy);
        strategyFileAccessor.init(mStrategiesPath, strategyFSMetadataProvider);


        String[] mask = new String[]{"*.lua"};
        FileEnumerator enumeratorStandardIndi = indiFileAccessor.enumerator(mask, false);
        if (enumeratorStandardIndi == null)
            throw new NullPointerException("Indicator fileEnumerator is null");

        FileEnumerator enumeratorStandardStrategies = strategyFileAccessor.enumerator(mask, false);
        if (enumeratorStandardStrategies == null)
            throw new NullPointerException("Strategy fileEnumerator is null");


        //create IndicoreManager and Host
        IndicoreManager indicoreManager = IndicoreManager.createInstance();
        Host host =  new SimpleHost();
        host.setAppPath(System.getProperty("user.dir"));

        Domain domain = indicoreManager.createDomain("Main", "Main domain");
        LoadMetadata loadMetadata = new LoadMetadataDefault(host);

        //load indicators
        indicoreManager.loadIntoDomain(domain, indiFileAccessor, enumeratorStandardIndi, loadMetadata);

        //load strategies
        indicoreManager.loadIntoDomain(domain, strategyFileAccessor, enumeratorStandardStrategies, loadMetadata);

        //prepare price data
        TickPriceStorage storage = new TickPriceStorage
                (
                "DataTick",
                "EUR/USD",
                4,
                4,
                0.01,
                false,
                true,
                1,
                1000,
                1);

        CsvTickDataParser csvTickDataParser = new CsvTickDataParser(mPriceDataPath);

        if (!csvTickDataParser.init())
        {
            System.out.println(String.format("Error: could not load data prices from path: %s", mPriceDataPath));
            return ;
        }
        preparePriceData(storage, csvTickDataParser);

        //create strategy instance
        StrategyProfiles strategyProfiles = indicoreManager.getStrategyProfiles();
        StrategyProfile strategyProfile = strategyProfiles.getProfile(mStrategyId);

        if (strategyProfile == null)
        {
            System.out.println(String.format("Error: strategy %s is not found.", mStrategyId));
            return ;
        }

        Parameters params = strategyProfile.getParameters();
        StrategyInstance instance = strategyProfile.createInstance(host,  storage.getBidPrices(), storage.getAskPrices(),
            params);

        //run prepare method
        if (!instance.prepare(false))
        {
            System.out.println("Error: cannot prepare instance of the strategy.");
            return ;
        }

        //update price data
        {
            //update initial values
            if (!instance.update())
            {
                System.out.println("Error: cannot update instance of the strategy.");
                return ;
            }

            //update next tics
            while (csvTickDataParser.loadNextTick(storage))
            {
                if (!instance.update())
                {
                    System.out.println("Error: cannot update instance of the strategy.");
                    return ;
                }
            }
        }
    }

    private static void preparePriceData(TickPriceStorage storage, CsvTickDataParser csvTickDataLoader) {

        long ticksCount = csvTickDataLoader.getTicksCount();
        long initialTicksCount = ticksCount > 100 ? 100 : ticksCount / 2;

        csvTickDataLoader.loadNextTicks(storage, initialTicksCount);
    }


    private static boolean parseCmdParams(String[] args) throws Exception {

        if (args.length == 0) {
            SampleParams.printHelp(PROG_NAME);
            return false;
        }

        SampleParams sampleParam = new SampleParams(args);
        sampleParam.checkObligatoryParams();
        mStrategyId = sampleParam.getStrategyID();
        mIndicatorsPath = sampleParam.getIndicatorsPath();
        mStrategiesPath = sampleParam.getStrategiesPath();
        mPriceDataPath = sampleParam.getDataPath();

        if (mStrategyId.isEmpty())
        {
            System.out.println("You does not specify the strategy_id. " +
                        "Sample will be run the MACROSS strategy" +
                        "and run strategy with default parameters.");

            mStrategyId = "MACROSS";
        }


        if (!Files.exists(Paths.get(mIndicatorsPath)))
        {
            System.out.println(String.format("Error: specified path %s does not exists", mIndicatorsPath));
            return false;
        }

        if (!Files.exists(Paths.get(mStrategiesPath)))
        {
            System.out.println(String.format("Error: specified path %s does not exists", mStrategiesPath));
            return false;
        }

        if (!Files.exists(Paths.get(mPriceDataPath)))
        {
            System.out.println(String.format("Error: specified path %s does not exists", mPriceDataPath));
            return false;
        }

        return true;
    }

    public static String parseCalendar(Calendar calendar) {
        Date date = calendar.getTime();
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
        try {
            return format.format(date);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "n/a";
    }

}