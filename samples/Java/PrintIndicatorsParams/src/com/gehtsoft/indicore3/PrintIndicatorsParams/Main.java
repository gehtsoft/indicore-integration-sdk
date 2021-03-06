package com.gehtsoft.indicore3.PrintIndicatorsParams;


import com.gehtsoft.indicore3.PrintIndicatorsParams.SampleParams.SampleParams;
import com.gehtsoft.indicore3.*;

import java.util.ArrayList;
import java.util.List;


public class Main {

    private static final String PROG_NAME = "PrintIndicatorsParams";
    private static IndicoreManager mIndicoreManager;

    static {
        System.loadLibrary("indicore3_jni");
    }

    public static void main(String[] args) throws IndicoreException {

        if (args.length == 0) {
            SampleParams.printHelp(PROG_NAME);
            return;
        }

        try {
            SampleParams params = new SampleParams(args);
            params.checkObligatoryParams();

            mIndicoreManager = IndicoreManager.createInstance();
            Domain domain = mIndicoreManager.createDomain("LoadIndicatorsList", "LoadIndicatorsList domain");
            List<IndicatorProfile> profiles = loadIndicators(domain, params.getIndicatorsPath());

            StringBuilder sb = new StringBuilder();

            sb.append("Total indicators ")
                    .append(profiles.size())
                    .append("\n");

            for (IndicatorProfile profile : profiles) {
                sb.append("ID=").append(profile.getID());
                sb.append(", Name=").append(profile.getName());
                sb.append(", Source=").append(profile.getRequiredSource());
                sb.append(", Type=").append(profile.getIndicatorType());
                sb.append("\n");

                Parameters parameters = profile.getParameters();
                for (int i = 0; i < parameters.size(); i++) {
                    Parameter parameter = parameters.getParameter(i);
                    String paramData = parseParameter(parameter);
                    sb.append(paramData);
                    sb.append("\n");
                }
            }

            System.out.println(sb.toString());
        }
        catch (Exception ex) {
            System.out.println(ex.getLocalizedMessage());
        }

        mIndicoreManager.dispose();
    }

    private static String parseParameter(Parameter parameter) {
        StringBuilder sb =  new StringBuilder();
        sb.append("  ");
        sb.append(parameter.getID()).append(", ");
        sb.append(parameter.getName()).append(", ");
        sb.append(parameter.getType()).append(", ");
        sb.append(parameter.defaultValue().getString());
        sb.append("\n");

        ParameterAlternatives alternatives = parameter.getAlternatives();
        if (parameter.hasAlternatives())
        {
            for (int j = 0; j < alternatives.size(); j++) {
                ParameterAlternative alternative = alternatives.getAlternative(j);
                String id = alternative.getID();
                String name = alternative.getName();
                ParameterConstant value = alternative.value();
                String type = value.getType().toString();
                sb.append("    ");
                sb.append(id).append(", ");
                sb.append(name).append(", ");
                sb.append(value).append(", ");
                sb.append(type);
            }
        }
        return sb.toString();
    }

    private static List<IndicatorProfile> loadIndicators(Domain domain, String path) {

        FileSystemAccessor fsa = new FileSystemAccessor();
        FileSystemMetadataProviderDefault pd = new FileSystemMetadataProviderDefault(Profile.Language.Lua, Profile.ObjectType.Indicator);

        List<IndicatorProfile> result = new ArrayList<>();

        try {
            BaseHostImpl host = new BaseHostImpl();
            fsa.init(path, pd);
            FileEnumerator enumerator = fsa.enumerator(new String[]{"*.lua"}, false);
            LoadErrorList ex = mIndicoreManager.loadIntoDomain(domain, fsa, enumerator, new LoadMetadataDefault(host));

            IndicatorProfiles profiles = mIndicoreManager.getIndicatorProfiles();
            if (profiles == null)
                throw new Exception("instance of IndicatorProfiles is null");

            for (IndicatorProfile profile : profiles)
                    result.add(profile);


            System.out.println("Loading " + path + " success end");


        } catch (Exception e) {
            System.out.println("Loading " + path + " failed:" + e.getMessage());
        }

        return result;
    }


}