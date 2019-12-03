package com.gehtsoft.indicore3.CalculateIndicator.SampleParams;

public class SampleParams {

    private final String INDICATORS_PATH_NOT_SPECIFIED = "'Indicators_dir_path' is not specified (/p|-p|/indicators_path|--indicators_path)";
    private final String INDICATORS_ID_NOT_SPECIFIED = "'Indicators_dir_path' is not specified (/p|-p|/indicators_path|--indicators_path)";

    // Getters

    public String getIndicatorID() {
        return mIndicatorID;
    }

    private String mIndicatorID;

    public String getIndicatorsPath() {
        return mIndicatorsPath;
    }

    private String mIndicatorsPath;

    public static void printHelp(String procName) {
        System.out.println(procName + " sample parameters:\n");

        System.out.println("/indicators_path | --indicators_path | /p | -p");
        System.out.println("Indicators directory path.\n");

        System.out.println("/indicatorid | --indicatorid | /i | -i");
        System.out.println("Indicator ID.\n");
    }

    // Check obligatory login parameters and sample parameters
    public void checkObligatoryParams() throws Exception {
        if (getIndicatorsPath().isEmpty()) {
            throw new Exception(INDICATORS_PATH_NOT_SPECIFIED);
        }
    }

    // Print process name and sample parameters
    private void printSampleParams(String procName, SampleParams prm) {
        System.out.println(String.format("Running %s with arguments:", procName));
        if (prm != null)
            System.out.println(String.format("Indicators_dir_path='%s'\nIndicatorID='%s'", prm.getIndicatorsPath(), prm.getIndicatorID()));
    }

    // ctor
    public SampleParams(String[] args) {

        // Get parameters with short keys
        mIndicatorsPath = getArgument(args, "p");
        mIndicatorID = getArgument(args, "i");

        // If parameters with short keys are not specified, get parameters with long keys
        if (mIndicatorsPath.isEmpty())
            mIndicatorsPath = getArgument(args, "indicators_path");

        if (mIndicatorID.isEmpty())
            mIndicatorID = getArgument(args, "indicatorid");
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

































