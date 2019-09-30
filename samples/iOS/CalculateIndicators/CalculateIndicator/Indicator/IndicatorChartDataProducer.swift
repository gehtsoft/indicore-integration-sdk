import Foundation

class IndicatorChartDataProducer
{
    private var profile: IndicoreIndicatorProfile?
    private var parameters: IndicoreParameters?
    private var indicator: Indicator?
    
    private var arrayOfNotLivePrices: Array<PriceSource>?
    private var arrayOfLivePrices: Array<PriceSource>?
    
    private var isStarted = false
    private let numberOfLivePrices = 80
    
    private var priceUpdatedCallback: ((IndicatorChartData) -> ())?
    private var thread: Thread?
    
    var isIndicatorDrawOnMainChart: Bool
    {
        get { return indicator!.isDrawOnMainChart }
    }
    
    init?(profile: IndicoreIndicatorProfile, parameters: IndicoreParameters)
    {
        self.profile = profile
        self.parameters = parameters
        
        createIndicator()
        if indicator == nil
        {
            return nil
        }
        
        let updated = indicator?.appendPriceSources(priceSources: arrayOfNotLivePrices!)
        if updated == false
        {
            return nil
        }
    }
    
    func createIndicator()
    {
        let isBarChart = (profile?.requiredSource() == .eIndicoreBarSource)
        
        // load price sources from a file
        let priceSourceLoader = PriceSourceLoader(isBarChart: isBarChart)
        priceSourceLoader.load()
        
        // create an indicator instance
        indicator = Indicator(name: priceSourceLoader.name!, instrument: priceSourceLoader.instrument!, tf: priceSourceLoader.timeframe!, precision: priceSourceLoader.precision!, pipSize: priceSourceLoader.pipSize!, supportsVolume: priceSourceLoader.supportsVolume!, profile: profile!, parameters: parameters!, isBarChart: isBarChart)
        
        let priceSourcesCount = priceSourceLoader.priceSources?.count
        let numberOnNotLivePrices = priceSourcesCount! - numberOfLivePrices
        
        arrayOfNotLivePrices = arrayTake(floor: 0, count: numberOnNotLivePrices, arrayIn: priceSourceLoader.priceSources!)
        arrayOfLivePrices = arrayTake(floor: numberOnNotLivePrices, count: numberOfLivePrices, arrayIn: priceSourceLoader.priceSources!)
    }
    
    func subscribeUpdates(callback: @escaping (IndicatorChartData) -> ())
    {
        priceUpdatedCallback = callback
    }
    
    func unsubscribeUpdates()
    {
        priceUpdatedCallback = nil
    }
    
    func started() -> Bool
    {
        return isStarted
    }
    
    @objc func produceIndicatorLiveData()
    {
        // simulate adding live prices to the indicator
        for livePriceSource in arrayOfLivePrices!
        {
            if isStarted == false { break }
            let updated = indicator!.appendPriceSource(priceSource: livePriceSource)
            if updated == false { break }
            self.notifyIndicatorChartDataUpdated()
            usleep(500000) // 0.5 second
        }
        
        isStarted = false
    }
    
    func notifyIndicatorChartDataUpdated()
    {
        DispatchQueue.main.async
        {
            if let priceUpdatedCallbackValue = self.priceUpdatedCallback
            {
                let indicatorChartData = (self.indicator?.indicatorChartData)!
                priceUpdatedCallbackValue(indicatorChartData)
                //print("The last updated index: \(indicatorChartData.indicatorConfigurations[0].indicatorItemsCount())")
            }
        }
    }
    
    func startProduceLivePrices()
    {
        isStarted = true
        thread = Thread(target: self, selector: #selector(produceIndicatorLiveData), object: nil)
        thread?.start()
        //print("Producer started")
    }
    
    func stopProduceLivePrices()
    {
        if isStarted == true
        {
            isStarted = false
            
            while thread!.isFinished == false
            {
                usleep(1000);
            }
        }
        //print("Producer stopped")
    }
    
    func arrayTake<T>(floor: Int, count: Int, arrayIn: Array<T>) -> Array<T>
    {
        let ceiling = floor + count
        return Array<T>(arrayIn[floor..<ceiling])
    }
}
