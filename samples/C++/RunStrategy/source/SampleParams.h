#pragma once
#include <iostream>
#include <string>

class SampleParams {

    const std::string INDICATORS_PATH_NOT_SPECIFIED = "'indicators' is not specified (/i|-i|/indicators|--indicators)";
    const std::string STRATEGIES_PATH_NOT_SPECIFIED = "'strategies' is not specified (/s|-s|/strategies|--strategies)";
    const std::string DATA_PATH_NOT_SPECIFIED = "'prices' is not specified (/p|-p|/prices|--prices)";

    std::string m_strategyID;
    std::string m_indicatorsPath;
    std::string m_strategiesPath;
    std::string m_dataPath;

public:

    std::string getStrategyID() const
    {
        return m_strategyID;
    }

    std::string getIndicatorsPath() const
    {
        return m_indicatorsPath;
    }

    std::string getStrategiesPath() const
    {
        return m_strategiesPath;
    }

    std::string getDataPath() const
    {
        return m_dataPath;
    }

    static void printHelp(const std::string& procName) {
        std::cout << procName << " sample parameters:\n" << std::endl;

        std::cout << "/indicators | --indicators | /i | -i" << std::endl;
        std::cout << "Indicators directory path. Parameter is required.\n" << std::endl;

        std::cout << "/strategies | --strategies | /s | -s" << std::endl;
        std::cout << "Strategies directory path. Parameter is required.\n" << std::endl;

        std::cout << "/id | --id | /strategy | -strategy" << std::endl;
        std::cout << "Strategy ID. Parameter is optional.\n" << std::endl;

        std::cout << "/prices | --prices | /p | -p" << std::endl;
        std::cout << "Path to csv file with prices. Parameter is required.\n" << std::endl;
    }

    // Check obligatory login parameters and sample parameters
    bool checkObligatoryParams(std::string &error) const
    {
        if (getIndicatorsPath().empty())
        {
            error = INDICATORS_PATH_NOT_SPECIFIED;
            return false;
        }
        if (getStrategiesPath().empty())
        {
            error = INDICATORS_PATH_NOT_SPECIFIED;
            return false;
        }
        if (getDataPath().empty())
        {
            error = DATA_PATH_NOT_SPECIFIED;
            return false;
        }
        return true;
    }

    // Print process name and sample parameters
    void printSampleParams(std::string procName) const
    {
        std::cout << "Running " << procName << " with arguments:" << std::endl;
        std::cout << "Indicators ='" << getIndicatorsPath() << "Strategies ='" << getStrategiesPath() << "'\nStrategy ='" << getStrategyID() <<
            "'\nPrices ='" << getDataPath() << "'" << std::endl;
    }

    // ctor
    SampleParams(int argc, char **argv) {

        // Get parameters with short keys
        m_indicatorsPath = getArgument(argc, argv, "i");
        m_strategiesPath = getArgument(argc, argv, "s");
        m_strategyID = getArgument(argc, argv, "n");
        m_dataPath = getArgument(argc, argv, "p");

        // If parameters with short keys are not specified, get parameters with long keys
        if (m_indicatorsPath.empty())
            m_indicatorsPath = getArgument(argc, argv, "indicators");

        if (m_strategiesPath.empty())
            m_strategiesPath = getArgument(argc, argv, "strategies");

        if (m_strategyID.empty())
            m_strategyID = getArgument(argc, argv, "name");

        if (m_dataPath.empty())
            m_dataPath = getArgument(argc, argv, "prices");
    }

private:
    static const char *getArgument(int argc, char **argv, const char *key)
    {
        for (int i = 1; i < argc; ++i)
        {
            if (argv[i][0] == '-' || argv[i][0] == '/')
            {
                int iDelimOffset = 0;
                if (strncmp(argv[i], "--", 2) == 0)
                    iDelimOffset = 2;
                else if (strncmp(argv[i], "-", 1) == 0 || strncmp(argv[i], "/", 1) == 0)
                    iDelimOffset = 1;

                if (_stricmp(argv[i] + iDelimOffset, key) == 0 && argc > i + 1)
                    return argv[i + 1];
            }
        }
        return "";
    }
};