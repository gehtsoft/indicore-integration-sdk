package com.gehtsoft.indicore3.RunStrategy.SampleParams;

public class SampleParams {

    private final String INDICATORS_PATH_NOT_SPECIFIED = "'indicators' is not specified (/i|-i|/indicators|--indicators)";
    private final String STRATEGIES_PATH_NOT_SPECIFIED = "'strategies' is not specified (/s|-s|/strategies|--strategies)";
    private final String DATA_PATH_NOT_SPECIFIED = "'prices' is not specified (/p|-p|/prices|--prices)";


    // Getters

    public String getStrategyID() {
        return mStrategyID;
    }

    private String mStrategyID;

    public String getIndicatorsPath() {
        return mIndicatorsPath;
    }

    private String mIndicatorsPath;

    public String getStrategiesPath() {return mStrategiesPath;}

    private String mStrategiesPath;

    public String getDataPath() { return mDataPath;}

    private String mDataPath;

    public static void printHelp(String procName) {
        System.out.println(procName + " sample parameters:\n");

        System.out.println("/indicators | --indicators | /i | -i");
        System.out.println("Indicators directory path. Parameter is required.\n");

        System.out.println("/strategies | --strategies | /s | -s");
        System.out.println("Strategies directory path. Parameter is required.\n");

        System.out.println("/id | --id | /strategy | -strategy");
        System.out.println("Strategy ID. Parameter is optional.\n");

        System.out.println("/prices | --prices | /p | -p");
        System.out.println("Path to csv file with prices. Parameter is required.\n");
    }

    // Check obligatory login parameters and sample parameters
    public void checkObligatoryParams() throws Exception {
        if (getIndicatorsPath().isEmpty()) {
            throw new Exception(INDICATORS_PATH_NOT_SPECIFIED);
        }
        if (getStrategiesPath().isEmpty())
        {
            throw new Exception(STRATEGIES_PATH_NOT_SPECIFIED);
        }
        if (getDataPath().isEmpty())
        {
            throw new Exception(DATA_PATH_NOT_SPECIFIED);
        }

    }

    // Print process name and sample parameters
    private void printSampleParams(String procName, SampleParams prm) {
        System.out.println(String.format("Running %s with arguments:", procName));
        if (prm != null)
            System.out.println(String.format("Indicators =='%s'\nStrategies='%s'\nStrategy='%s'\nPrices='%s'",
                    prm.getIndicatorsPath(), prm.getStrategiesPath(), prm.getStrategyID(), prm.getDataPath()));
    }

    // ctor
    public SampleParams(String[] args) {

        // Get parameters with short keys
        mIndicatorsPath = getArgument(args, "i");
        mStrategiesPath = getArgument(args, "s");
        mStrategyID = getArgument(args, "n");
        mDataPath = getArgument(args, "p");

        // If parameters with short keys are not specified, get parameters with long keys
        if (mIndicatorsPath.isEmpty())
            mIndicatorsPath = getArgument(args,"indicators");

        if (mStrategiesPath.isEmpty())
            mStrategiesPath = getArgument(args, "strategies");

        if (mStrategyID.isEmpty())
            mStrategyID = getArgument(args,"name");

        if (mDataPath.isEmpty())
            mDataPath = getArgument(args,"prices");

        if (mIndicatorsPath.isEmpty())
            mIndicatorsPath = getArgument(args, "indicators_path");
    }

    private String getArgument(String[] args, String sKey) {
        for (int i = 0; i < args.length; i++) {
            int iDelimOffset = 0;
            if (args[i].startsWith("--")) {
                iDelimOffset = 2;
            } else if (args[i].startsWith("-") || args[i].startsWith("/")) {
                iDelimOffset = 1;
            }

            if (args[i].substring(iDelimOffset).equals(sKey) && (args.length > i + 1)) {
                return args[i + 1];
            }
        }
        return "";
    }
}

































