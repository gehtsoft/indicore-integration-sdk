# How to run a strategy

## Create a file accessor for loading Lua indicators.

```cpp
 AutoRelease<indicore3::FileSystemAccessor> indiFileAccessor(new indicore3::FileSystemAccessor());
 AutoRelease<indicore3::IFileSystemMetadataProvider> indiFSMetadataProvider(new          indicore3::FileSystemMetadataProvider(indicore3::ILanguageService::Lua,
 indicore3::ILanguageService::Indicator));
 
 indicore3::IError *indiError = nullptr;
 if (!indiFileAccessor->init(indicatorsPath.c_str(), indiFSMetadataProvider.get(), &indiError))
 {
 	 AutoRelease<indicore3::IError> autoIndiError(indiError);
 	 Utils::printIndicoreError(indiError);
 	 return -1;
 }
 ```
 
## Create a file accessor for loading Lua strategies.

```cpp
 AutoRelease<indicore3::FileSystemAccessor> strategiesFileAccessor(new indicore3::FileSystemAccessor());
 AutoRelease<indicore3::IFileSystemMetadataProvider> strFSMetadataProvider(new indicore3::FileSystemMetadataProvider(indicore3::ILanguageService::Lua,
 indicore3::ILanguageService::Strategy));

 if (!strategiesFileAccessor->init(strategiesPath.c_str(), strFSMetadataProvider.get(), &indiError))
 {
       AutoRelease<indicore3::IError> autoIndiError(indiError);
       Utils::printIndicoreError(indiError);
       return -1;
 }
 ```
 
## Create an enumerator of standard indicators.

```cpp
 const char *mask[] = { "*.lua", nullptr };
 std::string pathStandard = indicatorsPath;
 AutoRelease<indicore3::IFileEnumerator> enumeratorStandardIndi(indiFileAccessor->enumerator(indicatorsPath.c_str(), mask, false, &indiError));
 if (!enumeratorStandardIndi.get())
 {
 	 AutoRelease<indicore3::IError> autoIndiError(indiError);
 	 Utils::printIndicoreError(indiError);
 	 return -1;
 }
 ```
 
## Create an enumerator of standard strategies.

```cpp
 AutoRelease<indicore3::IFileEnumerator> enumeratorStandardStrategies(strategiesFileAccessor->enumerator(strategiesPath.c_str(), mask, false, &indiError));
 if (!enumeratorStandardStrategies.get())
 {
        AutoRelease<indicore3::IError> autoIndiError(indiError);
        Utils::printIndicoreError(indiError);
        return -1;
}
```

## Create an instance of IndicoreManager and an instance of IHost.

```cpp
 AutoRelease<indicore3::IndicoreManager> indicoreManager(indicore3::IndicoreManager::createInstance());
 AutoRelease<indicore3::IHost> host(new SimpleHost());
Load indicators using ILoadMetadata and IDomain.

 indicore3::IDomain *domain = indicoreManager->createDomain("Main", "Main domain");
 
 AutoRelease<indicore3::ILoadMetadata> loadMetadata(new indicore3::LoadMetadata(host.get()));
 
 indicoreManager->loadIntoDomain(domain, indiFileAccessor.get(), enumeratorStandardIndi.get(), loadMetadata.get(), &indiError);
 if (indiError)
 {
 	 AutoRelease<indicore3::IError> autoIndiError(indiError);
 	 Utils::printIndicoreError(indiError);
 	 return -1;
 }
 ```

## Load strategies using ILoadMetadata.

```
 indicoreManager->loadIntoDomain(domain, strategiesFileAccessor.get(), enumeratorStandardStrategies.get(), loadMetadata.get(), &indiError);
 if (indiError)
 {
         AutoRelease<indicore3::IError> autoIndiError(indiError);
         Utils::printIndicoreError(indiError);
         return -1;
 }
 ```
 
## Prepare price data using TickPriceStorage.

```cpp
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
 ```

## Create a strategy instance using IStrategyProfile and IParameters.

```cpp
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
 ```
 
## Run the prepare method of the strategy instance.

```cpp
 if (!instance->prepare(false, &indiError))
 {
 	 AutoRelease<indicore3::IError> autoIndiError(indiError);
 	 Utils::printIndicoreError(indiError);
 	 return -1;
 }
 ```

## Update price data of the strategy instance: update initial values and then next ticks.

```cpp
 if (!instance->update(&indiError))
 {
       AutoRelease<indicore3::IError> autoIndiError(indiError);
       Utils::printIndicoreError(indiError);
       return -1;
 }
 while (csvTickDataLoader.loadNextTick(storage.get()))
 {
       if (!instance->update(&indiError))
       {
           AutoRelease<indicore3::IError> autoIndiError(indiError);
           Utils::printIndicoreError(indiError);
           return -1;
       }
 }
 ```
