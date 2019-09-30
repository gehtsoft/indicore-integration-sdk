#include "stdafx.h"
#include "SampleParams.h"

/**
  Prints list of installed indicators
 */
int main(int argc, char* argv[])
{
	std::string indicatorsPath;
	if (!parseParams(argc, argv, indicatorsPath))
		return 1;

    //create file accessor for loading Lua indicators
    AutoRelease<indicore3::FileSystemAccessor> fileAccessor(new indicore3::FileSystemAccessor());
    std::string appPath = Utils::getAppPath();
    AutoRelease<indicore3::IFileSystemMetadataProvider> fsmp(new indicore3::FileSystemMetadataProvider(indicore3::ILanguageService::Lua,
        indicore3::ILanguageService::Indicator));

    indicore3::IError *indiError = nullptr;
    if (!fileAccessor->init(indicatorsPath.c_str(), fsmp.get(), &indiError))
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        printIndicoreError(indiError);
        return -1;
    }

    const char *mask[] = { "*.lua", nullptr};

    //create an enumerator of standard indicators
    std::string pathStandard = indicatorsPath;
    AutoRelease<indicore3::IFileEnumerator> enumeratorStandard(fileAccessor->enumerator(mask, false, &indiError));
    if (!enumeratorStandard.get())
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        printIndicoreError(indiError);
        return -1;
    }

    //create IndicoreManager and Host
    AutoRelease<indicore3::IndicoreManager> indicoreManager(indicore3::IndicoreManager::createInstance());
    AutoRelease<indicore3::IHost> host(new indicore3::BaseHostImpl());

    indicore3::IDomain *domain = indicoreManager->createDomain("LoadIndicatorsList", "LoadIndicatorsList domain");

    //load indicators
    AutoRelease<indicore3::ILoadMetadata> loadMetadata(new indicore3::LoadMetadata(host.get()));

    indicoreManager->loadIntoDomain(domain, fileAccessor.get(), enumeratorStandard.get(), loadMetadata.get(), &indiError);
    if (indiError)
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        printIndicoreError(indiError);
        return -1;
    }

    AutoRelease<indicore3::IIndicatorProfiles> indicators(indicoreManager->getIndicatorProfiles());
    std::cout << "Total indicators " << indicators->size() << std::endl;

    //print all indicators info
    for (index_t index = 0; index < indicators->size(); ++index)
    {
        indicore3::IIndicatorProfile *profile = indicators->getProfile(index);
        indicore3::IIndicatorProfile::IndicatorType indiType = profile->getIndicatorType();

        std::string type, source;
        if (indiType == indicore3::IIndicatorProfile::Indicator)
            type = "indicator";
        else if (indiType == indicore3::IIndicatorProfile::Oscillator)
            type = "oscillator";
        else if (indiType == indicore3::IIndicatorProfile::View)
            type = "view";
        else
            type = "unknown";

        if (profile->getRequiredSource() == indicore3::IIndicatorProfile::Bar)
            source = "bar";
        else
            source = "tick";

        std::cout << "ID=" << profile->getID()   << ", "
                  << "Name='" << profile->getName() << "', "
                  << "Source="<< source << ", "
                  << "Type=" << type << std::endl;

        AutoRelease<indicore3::IParameters> parameters(profile->getParameters());

        //print parameters
        for (index_t i = 0; i < parameters->size(); i++)
        {
            indicore3::IParameter* param = parameters->getParameter(i);

            std::cout << "  "
                      << param->getID() << " "
                      << param->getName() << " "
                      << decodeType(param->getType()) << " "
                      << param->defaultValue()->getString()
                      << std::endl;

            indicore3::IParameterAlternatives *alternativeParam = param->getAlternatives();
            if (alternativeParam != nullptr)
            {
                for (index_t j = 0; j < alternativeParam->size(); j++)
                {
                    const indicore3::IParameterAlternative *alt = alternativeParam->getAlternative(j);
                    const indicore3::IParameterConstant *value = alt->value();

                    std::cout << "      "
                              << alt->getID() << " "
                              << alt->getName() << " "
                              << decodeType(value->getType()) << " "
                              << value->getString() << std::endl;
                }
            }
        }
    }

    return 0;
}

bool parseParams(int argc, char* argv[], std::string& indicatorsPath)
{
	const std::string progName = "LoadIndicatorsList";

	if (argc == 1)
	{
		SampleParams::printHelp(progName);
		return false;
	}

	SampleParams simpleParams(argc, argv);

	std::string error;
	if (!simpleParams.checkObligatoryParams(error))
	{
		std::cout << error << std::endl;
		return false;
	}

	simpleParams.printSampleParams(progName);
	indicatorsPath = simpleParams.getIndicatorsPath();

	return true;
}


const char *decodeType(indicore3::IParameterConstant::Type type)
{
    switch (type)
    {
        case indicore3::IParameterConstant::Nil:
            return "Nil";
        case indicore3::IParameterConstant::Boolean:
            return "Boolean";
        case indicore3::IParameterConstant::Integer:
            return "Integer";
        case indicore3::IParameterConstant::Double:
            return "Double";
        case indicore3::IParameterConstant::String:
            return "String";
        case indicore3::IParameterConstant::Color:
            return "Color";
        case indicore3::IParameterConstant::Date:
            return "Date";
        case indicore3::IParameterConstant::File:
            return "File";
        case indicore3::IParameterConstant::Object:
            return "Object";
    }
    return "Unknown";
}

/**
  Prints an Indicore error to a console.
 */
void printIndicoreError(indicore3::IError *error)
{
    if (!error)
        return;
    for (index_t i = 0; i < error->size(); i++)
    {
        AutoRelease<const indicore3::IError::IErrorInfo> errorInfo(error->getError(i));
        std::cout << "Error: " << errorInfo->getText() << std::endl;
    }
}
