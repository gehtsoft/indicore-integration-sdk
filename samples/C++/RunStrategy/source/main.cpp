#include "stdafx.h"

#include "util/Utils.h"
#include "SampleParams.h"
#include "util/CsvTickDataParser.h"
#include "host/host.h"

bool parseCmdParams(int, char*[], std::string&, std::string&, std::string&, std::string&);
void preparePriceData(indicore3::TickPriceStorage *priceStorage, CsvTickDataLoader& csvTickDataLoader);

int main(int argc, char* argv[])
{
    std::string strategyId;
    std::string indicatorsPath;
    std::string strategiesPath;
    std::string priceDataPath;

    bool paramsAreValid = parseCmdParams(argc, argv, strategyId, indicatorsPath, strategiesPath, priceDataPath);
    if (!paramsAreValid)
        return 1;

    //create file accessor for loading Lua indicators
    AutoRelease<indicore3::FileSystemAccessor> indiFileAccessor(new indicore3::FileSystemAccessor());
    AutoRelease<indicore3::IFileSystemMetadataProvider> indiFSMetadataProvider(new indicore3::FileSystemMetadataProvider(indicore3::ILanguageService::Lua,
        indicore3::ILanguageService::Indicator));


    //create file accessor for loading Lua strategies
    AutoRelease<indicore3::FileSystemAccessor> strategiesFileAccessor(new indicore3::FileSystemAccessor());
    AutoRelease<indicore3::IFileSystemMetadataProvider> strFSMetadataProvider(new indicore3::FileSystemMetadataProvider(indicore3::ILanguageService::Lua,
        indicore3::ILanguageService::Strategy));


    indicore3::IError *indiError = nullptr;
    if (!indiFileAccessor->init(indicatorsPath.c_str(), indiFSMetadataProvider.get(), &indiError))
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        Utils::printIndicoreError(indiError);
        return -1;
    }

    if (!strategiesFileAccessor->init(strategiesPath.c_str(), strFSMetadataProvider.get(), &indiError))
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        Utils::printIndicoreError(indiError);
        return -1;
    }

    const char *mask[] = { "*.lua", nullptr };

    //create an enumerator of standard indicators
    AutoRelease<indicore3::IFileEnumerator> enumeratorStandardIndi(indiFileAccessor->enumerator(mask, false, &indiError));
    if (!enumeratorStandardIndi.get())
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        Utils::printIndicoreError(indiError);
        return -1;
    }

    //create an enumerator of standard strategies
    AutoRelease<indicore3::IFileEnumerator> enumeratorStandardStrategies(strategiesFileAccessor->enumerator(mask, false, &indiError));
    if (!enumeratorStandardStrategies.get())
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        Utils::printIndicoreError(indiError);
        return -1;
    }


    //create IndicoreManager and Host
    AutoRelease<indicore3::IndicoreManager> indicoreManager(indicore3::IndicoreManager::createInstance());
    AutoRelease<indicore3::IHost> host(new SimpleHost());

    indicore3::IDomain *domain = indicoreManager->createDomain("Main", "Main domain");

    //load indicators
    AutoRelease<indicore3::ILoadMetadata> loadMetadata(new indicore3::LoadMetadata(host.get()));

    indicoreManager->loadIntoDomain(domain, indiFileAccessor.get(), enumeratorStandardIndi.get(), loadMetadata.get(), &indiError);
    if (indiError)
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        Utils::printIndicoreError(indiError);
        return -1;
    }

    //load strategies
    indicoreManager->loadIntoDomain(domain, strategiesFileAccessor.get(), enumeratorStandardStrategies.get(), loadMetadata.get(), &indiError);
    if (indiError)
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        Utils::printIndicoreError(indiError);
        return -1;
    }

    //prepare price data
    AutoRelease<indicore3::TickPriceStorage> storage( new indicore3::TickPriceStorage(
                                                            "DataTick",                                    //name
                                                            "EUR/USD",                                     //instrument
                                                            4,                                             //precision
                                                            4,                                             //displayprecision
                                                            0.01,                                          //pipSize
                                                            false,                                         //supportVolume
                                                            true,                                          //alive
                                                            1,                                             //m_id
                                                            1000,                                          //limit
                                                            1));                                           //instrumentIndex

    CsvTickDataLoader csvTickDataLoader(priceDataPath.c_str());
    if (csvTickDataLoader.init() == false)
    {
        std::cout << "Error: could not load data prices from path:"<< priceDataPath << std::endl;
        return 1;
    }
    preparePriceData(storage.get(), csvTickDataLoader);

    //create strategy instance
    AutoRelease<indicore3::IStrategyProfiles> strategies(indicoreManager->getStrategyProfiles());
    indicore3::IStrategyProfile *profile = strategies->getProfile(strategyId.c_str());
    if (profile == nullptr)
    {
        std::cout << "Error: strategy " << strategyId << " is not found." << std::endl;
        return 1;
    }

    AutoRelease<indicore3::IParameters> params(profile->getParameters());
    AutoRelease<indicore3::IStrategyInstance> instance(profile->createInstance(host.get(), storage->getBidPrices(), storage->getAskPrices(), params.get()));
    if (instance.get() == nullptr)
    {
        std::cout << "Error: cannot create the strategy." << std::endl;
        return 1;
    }

    //run prepare method
    if (!instance->prepare(false, &indiError))
    {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        Utils::printIndicoreError(indiError);
        return -1;
    }

    //update price data
    {
        //update initial values
        if (!instance->update(&indiError))
        {
            AutoRelease<indicore3::IError> autoIndiError(indiError);
            Utils::printIndicoreError(indiError);
            return -1;
        }

        //update next tics
        while (csvTickDataLoader.loadNextTick(storage.get()))
        {
            if (!instance->update(&indiError))
            {
                AutoRelease<indicore3::IError> autoIndiError(indiError);
                Utils::printIndicoreError(indiError);
                return -1;
            }
        }
    }

    return 0;
}

bool parseCmdParams(int argc, char* argv[], std::string& strategyId, std::string& indicatorsPath, std::string& strategiesPath, std::string& priceDataPath)
{
    const std::string progName = "RunStrategy";

    if (argc == 1) {
        SampleParams::printHelp(progName);
        return false;
    }

    SampleParams sampleParam(argc, argv);
    std::string error;
    if (!sampleParam.checkObligatoryParams(error))
    {
        std::cout << error << std::endl;
        return false;
    }

    strategyId = sampleParam.getStrategyID();
    indicatorsPath = sampleParam.getIndicatorsPath();
    strategiesPath = sampleParam.getStrategiesPath();
    priceDataPath = sampleParam.getDataPath();

    sampleParam.printSampleParams(progName);

    if (strategyId.empty())
    {
        std::cout << "You does not specify the strategy_id. "
            << "Sample will be run the MACROSS strategy"
            << "and run strategy with default parameters."
            << std::endl;

        strategyId = "MACROSS";
    }

    if (!Utils::IsPathExist(indicatorsPath))
    {
        std::cout << "Error: specified path: " << indicatorsPath << " does not exists" << std::endl;
        return false;
    }

    if (!Utils::IsPathExist(strategiesPath))
    {
        std::cout << "Error: specified path: " << strategiesPath << " does not exists" << std::endl;
        return false;
    }

    if (!Utils::IsPathExist(priceDataPath))
    {
        std::cout << "Error: specified path: " << priceDataPath << " does not exists" << std::endl;
        return false;
    }

    return true;
}

void preparePriceData(indicore3::TickPriceStorage *priceStorage, CsvTickDataLoader& csvTickDataLoader)
{
    std::size_t ticksCount = csvTickDataLoader.getTicksCount();
    std::size_t initialTicksCount = ticksCount > 100 ? 100 : ticksCount / 2;

    csvTickDataLoader.loadNextTicks(priceStorage, initialTicksCount);
}