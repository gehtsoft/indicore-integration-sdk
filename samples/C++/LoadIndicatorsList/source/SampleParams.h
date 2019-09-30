#pragma once
#include <iostream>
#include <string>

class SampleParams {

	const std::string INDICATORS_PATH_NOT_SPECIFIED = "'indicators_dir_path' is not specified (/p|-p|/indicators_path|--indicators_path)";

	std::string m_indicatorsPath;

public:
	std::string getIndicatorsPath() const
	{
		return m_indicatorsPath;
	}

	static void printHelp(const std::string& procName) {
		std::cout << procName << " sample parameters:\n" << std::endl;

		std::cout << "/indicators_path | --indicators_path | /p | -p" << std::endl;
		std::cout << "Indicators directory path. Parameter is required.\n" << std::endl;
	}

	// Check obligatory login parameters and sample parameters
	bool checkObligatoryParams(std::string &error) const
	{
		if (getIndicatorsPath().empty())
		{
			error = INDICATORS_PATH_NOT_SPECIFIED;
			return false;
		}
		return true;
	}

	// Print process name and sample parameters
	void printSampleParams(std::string procName) const
	{
		std::cout << "Running " << procName << " with arguments:" << std::endl;
		std::cout << "Indicators_dir_path='" << getIndicatorsPath() << std::endl;
	}

	// ctor
	SampleParams(int argc, char **argv) {

		// Get parameters with short keys
		m_indicatorsPath = getArgument(argc, argv, "p");

		// If parameters with short keys are not specified, get parameters with long keys
		if (m_indicatorsPath.empty())
			m_indicatorsPath = getArgument(argc, argv, "indicators_path");
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