import Foundation

class Indicator
{
    var indicatorChartData: IndicatorChartData?
    var storage: IndicoreBarPriceStorage?
    let isBarChart: Bool?
    let profile: IndicoreIndicatorProfile?
    let parameters: IndicoreParameters?
    let indicatorInstance: IndicoreIndicatorInstance?
    
    var isDrawOnMainChart: Bool
    {
        get { return profile?.indicatorType() != .eIndicoreOscillator }
    }
    
    init?(name: String, instrument: String, tf: String, precision: Int, pipSize: Double, supportsVolume: Bool, profile: IndicoreIndicatorProfile, parameters: IndicoreParameters, isBarChart: Bool)
    {
        self.parameters = parameters
        self.profile = profile
        self.isBarChart = isBarChart
        
        self.storage = IndicoreBarPriceStorage(name: name, instrument: instrument, tf: tf, mode: IndicoreBarPriceStorageOpenMode.eIndicoreFirstTickNewBar, tradingDayOffset: 0, itradingWeekOffset: 0, precision: precision, displayprecision: precision, pipSize: pipSize, supportsVolume: supportsVolume, alive: true, identifier: 0, limit: 10000, instrumentIndex: 0)
        
        if storage == nil
        {
            return nil
        }
        
        let priceStream = storage?.bidPrices()
        
        if priceStream == nil
        {
            return nil
        }
        
        indicatorInstance = profile.createInstance(with: profile.host(), source: priceStream, params: parameters)
        
        if indicatorInstance == nil
        {
            return nil
        }
        
        do
        {
            try indicatorInstance!.prepare(withOnlyName: false)
        }
        catch let error as NSError
        {
            printError(error: error)
            return nil
        }
    }
    
    func appendPriceSources(priceSources: [PriceSource]) -> Bool
    {
        for priceSource in priceSources
        {
            storage?.addBar(withDate: priceSource.date, bidopen: priceSource.bidopen, bidhigh: priceSource.bidhigh, bidlow: priceSource.bidlow, bidclose: priceSource.bidclose, askopen: priceSource.askopen, askhigh: priceSource.askhigh, asklow: priceSource.asklow, askclose: priceSource.askclose, volume: priceSource.volume)
        }
        return calculate()
    }
    
    func appendPriceSource(priceSource: PriceSource) -> Bool
    {
        storage?.addBar(withDate: priceSource.date, bidopen: priceSource.bidopen, bidhigh: priceSource.bidhigh, bidlow: priceSource.bidlow, bidclose: priceSource.bidclose, askopen: priceSource.askopen, askhigh: priceSource.askhigh, asklow: priceSource.asklow, askclose: priceSource.askclose, volume: priceSource.volume)
        
        return calculate()
    }
    
    private func calculate() -> Bool
    {
        do
        {
            try indicatorInstance?.update(true) // recalculate
            
            if collectCalculatedData(storage: storage!, isBarChart: isBarChart!) == false // get the calculated data from the indicator
            {
                showError(msg: "Unknown error: cannot calculate indicatator.")
                return false
            }
        }
        catch let error as NSError
        {
            printError(error: error)
            return false
        }
        
        return true
    }

    private func collectCalculatedData(storage: IndicoreBarPriceStorage, isBarChart: Bool) -> Bool
    {
        if indicatorChartData == nil
        {
            // get data from the indicator for the first time - here an IndicatorChartData object is created,
            // data from the indicator and the instrument chart are added to it
            return initIndicatorChartData(storage: storage, isBarChart: isBarChart)
        }
        else
        {
            // get data from the indicator not for the first time - here new data is added
            // to the already created IndicatorChartData object
            return updateIndicatorChartData(storage: storage, isBarChart: isBarChart)
        }
    }
    
    private func initIndicatorChartData(storage: IndicoreBarPriceStorage, isBarChart: Bool) -> Bool
    {
        let indicatorConfsFromOutputStreams = getDataFromOutputStreams()
        let indicatorConfsFromOutputGroups = getDataFromGroups()
        
        var indicatorConfigurations = [IndicatorConfiguration]()
        indicatorConfigurations += indicatorConfsFromOutputStreams!
        indicatorConfigurations += indicatorConfsFromOutputGroups!
        
        if indicatorConfigurations.count == 0
        {
            // we received no data from the indicator
            return false
        }
        
        let candlesCount = storage.size()
        if candlesCount == 0
        {
            return false
        }
        // get data from IndicoreBarPriceStorage to draw the instrument chart
        var chartItems = [ChartItem]()
        for i: UInt in 0..<candlesCount
        {
            let o = storage.bidOpen(at: i)
            let c = storage.bidClose(at: i)
            let h = storage.bidHigh(at: i)
            let l = storage.bidLow(at: i)
            let oleDate = storage.date(at: i)
            let item = ChartItem(open: o,close: c,hight: h,low: l, oleDate: oleDate)
            chartItems.append(item)
        }
        
        let instr = storage.instrument()
        let chartData = IndicoreChartData(instrument: instr!, chartItems: chartItems, isBarChart: isBarChart)
        indicatorChartData = IndicatorChartData(chartData: chartData, indicatorName: (indicatorInstance?.name())!, indicatorConfigurations: indicatorConfigurations)
        return true
    }
    
    // IndicoreOutputStream is drawn as a line or a histogram.
    // It is always a tick stream.
    // NB: For simplicity, we ignore the line style, we assume that it is always 'solid'
    private func getDataFromOutputStreams() -> [IndicatorConfiguration]?
    {
        var indicatorConfigurations = [IndicatorConfiguration]()
        
        let streamCount = indicatorInstance?.streamCount()
        if streamCount == 0
        {
            return indicatorConfigurations
        }
        
        for i: UInt in 0..<streamCount!
        {
            let stream = indicatorInstance?.stream(at: i)
            if (stream?.isInGroup())!
            {
                continue // All streams contained in *OutputGroup are also duplicated here as IndicoreOuptputStream objects.
                         // Accordingly, if we have one IndicoreOutputGroupCandle, here it will be represented by four streams:
                         // 'open', 'high', 'close', 'low'. For these streams, isInGroup() will return 'true'. Such streams should be
                         // processed as *OutputGroup, otherwise it will be difficult to define which price of the candle the stream contains.
            }
            let size = stream?.size()
            var indicatorItems = [IndicatorItem]()
            for j: UInt in 0..<size!
            {
                let price = stream?.price(at: j)
                let oleDate = stream?.date(at: j)
                let item = IndicatorItem(price: price!, oleDate: oleDate!)
                indicatorItems.append(item)
            }
            let lineStyle = stream?.lineStyle()
            let lineWidth = stream?.lineWidth()
            let type = parseOutputStreamType(type: stream!.type())
            let color = IndicoreColorUtils.nativeColor(fromBgr: stream!.color())
            let levels = getLevels(outputStream: stream!)
            let indiConfig = IndicatorConfiguration(indicatorItems: indicatorItems, color: color, lineWidth: lineWidth!, lineStyle: lineStyle!, type: type, isChannel: false, levels: levels)
            indicatorConfigurations.append(indiConfig)
        }
        
        return indicatorConfigurations
    }
    
    func parseOutputStreamType(type: IndicoreOutputType) -> IndicatorConfigurationType
    {
        if type == .eIndicoreBarOutputType
        {
            return IndicatorConfigurationType.ICTypeBar
        }
        else if type == .eIndicoreDotOutputType
        {
            return IndicatorConfigurationType.ICTypeDot
        }
        else
        {
            return IndicatorConfigurationType.ICTypeLine
        }
    }
    
    // Groups are objects that allow drawing:
    // - 'Candles' (IndicoreOutputGroupCandle);
    // - 'Channel' (IndicoreOutputGroupChannel) - two lines and a filled area between them, it is used in the Ichimoku indicator
    private func getDataFromGroups() -> [IndicatorConfiguration]?
    {
        var indicatorConfigurations = [IndicatorConfiguration]()
        
        let outputGroupCount = indicatorInstance?.outputGroupCount()
        for i: UInt in 0..<outputGroupCount!
        {
            let outputGroup = indicatorInstance?.outputGroup(at: i)
            
            if outputGroup?.type() == .eIndicoreOutputGroupCandle
            {
                let outputGroupCandle = outputGroup as! IndicoreOutputGroupCandle
                let priceBarStream = outputGroupCandle.barStream()
                let candlesCount = priceBarStream?.size()
                
                var indicatorItems = [IndicatorItem]()
                for j: UInt in 0..<candlesCount!
                {
                    let o = priceBarStream?.openPrice(at: j)
                    let c = priceBarStream?.closePrice(at: j)
                    let h = priceBarStream?.highPrice(at: j)
                    let l = priceBarStream?.lowPrice(at: j)
                    let oleDate = priceBarStream?.date(at: j)
                    let item = IndicatorItem(openPrice: o!, closePrice: c!, lowPrice: l!, highPrice: h!, oleDate: oleDate!)
                    indicatorItems.append(item)
                }
                
                let lineWidth = outputGroupCandle.closeStream()?.lineWidth() // for simplicity, we use only the line width of the 'close' price
                let lineStyle = outputGroupCandle.closeStream()?.lineStyle() // for simplicity, we use only the line width of the 'close' price
                let type = IndicatorConfigurationType.ICTypeCandle
                let indiConfig = IndicatorConfiguration(indicatorItems: indicatorItems, color: nil, lineWidth: lineWidth!, lineStyle: lineStyle!, type: type, isChannel: false, levels: nil)
                indicatorConfigurations.append(indiConfig)
            }
            else if outputGroup?.type() == .eIndicoreOutputGroupChannel
            {
                let outputGroupChannel = outputGroup as! IndicoreOutputGroupChannel
                
                let firstStream = outputGroupChannel.firstStream()  // the first line of a channel
                let firstStreamCount = firstStream?.size()
                var firstIndicatorItems = [IndicatorItem]()
                for j in 0..<firstStreamCount!
                {
                    let price = firstStream?.price(at: j)
                    let date = firstStream?.date(at: j)
                    let item = IndicatorItem(price: price!, oleDate: date!)
                    firstIndicatorItems.append(item)
                }
                
                var lineStyle = firstStream?.lineStyle()
                var lineWidth = firstStream?.lineWidth()
                var type = IndicatorConfigurationType.ICTypeLine
                var color = IndicoreColorUtils.nativeColor(fromBgr: (firstStream?.color())!)
                var levels = getLevels(outputStream: firstStream!)
                var indiConfig = IndicatorConfiguration(indicatorItems: firstIndicatorItems, color: color, lineWidth: lineWidth!, lineStyle: lineStyle!, type: type, isChannel: true, levels: levels)
                indicatorConfigurations.append(indiConfig)
                
                let secondStream = outputGroupChannel.secondStream()  // the second line of a channel
                let secondStreamCount = secondStream?.size()
                var secondIndicatorItems = [IndicatorItem]()
                for j in 0..<secondStreamCount!
                {
                    let price = secondStream?.price(at: j)
                    let date = secondStream?.date(at: j)
                    let item = IndicatorItem(price: price!, oleDate: date!)
                    secondIndicatorItems.append(item)
                }
                
                lineStyle = secondStream?.lineStyle()
                lineWidth = secondStream?.lineWidth()
                type = IndicatorConfigurationType.ICTypeLine
                color = IndicoreColorUtils.nativeColor(fromBgr: secondStream!.color())
                levels = getLevels(outputStream: secondStream!)
                indiConfig = IndicatorConfiguration(indicatorItems: secondIndicatorItems, color: color, lineWidth: lineWidth!, lineStyle: lineStyle!, type: type, isChannel: true, levels: levels)
                indicatorConfigurations.append(indiConfig)
            }
        }
        return indicatorConfigurations
    }
    
    // Get level lines.
    // A level line is a line drawn along the X axis.
    func getLevels(outputStream: IndicoreOutputStream) -> [LevelLine]?
    {
        var levelLines = [LevelLine]()
        let levelsCount = outputStream.levelsCount()
        for i in 0..<levelsCount
        {
            let y = outputStream.level(at: i)
            let width = outputStream.levelLineWidth(at: i)
            let style = outputStream.levelLineStyle(at: i)
            let color = outputStream.levelLineColor(at: i)
            
            // Fix for some indicators: some level lines are drawn using the white color on the white background,
            // I change the color of such lines from white to lightGray.
            // FXTS uses a more complex algorithm to choose color for these lines.
            var nativeColor: UIColor?
            if color > 0
            {
                nativeColor = IndicoreColorUtils.nativeColor(fromBgr: color)
            }
            else
            {
                nativeColor = UIColor.lightGray
            }
            let levelLine = LevelLine(y: y, width: width, style: style, color: nativeColor!)
            levelLines.append(levelLine)
        }
        return levelLines.count > 0 ? levelLines : nil
    }

    private func updateIndicatorChartData(storage: IndicoreBarPriceStorage, isBarChart: Bool) -> Bool
    {
        let streamCount = indicatorInstance!.streamCount()
        if streamCount == 0
        {
            return false
        }
        
        var indicatorConfIndex = 0
        
        for i: UInt in 0..<streamCount
        {
            let stream = indicatorInstance!.stream(at: i)
            if (stream!.isInGroup())
            {
                continue
            }
        
            let indicatorConfiguration = indicatorChartData!.indicatorConfigurations[indicatorConfIndex]
            let existingIndicatorItemsCount = UInt(indicatorConfiguration.indicatorItemsCount())
            let lastUpdateIndex = UInt((indicatorInstance?.lastUpdate())!)
            
            if existingIndicatorItemsCount < lastUpdateIndex
            {
                for j: UInt in existingIndicatorItemsCount..<lastUpdateIndex
                {
                    let price = stream?.price(at: j)
                    let oleDate = stream?.date(at: j)
                    let item = IndicatorItem(price: price!, oleDate: oleDate!)
                    indicatorConfiguration.appendItem(indicatorItem: item)
                }
            }
            indicatorConfIndex += 1
        }
        
        let outputGroupCount = indicatorInstance!.outputGroupCount()
        for i: UInt in 0..<outputGroupCount
        {
            let outputGroup = indicatorInstance?.outputGroup(at: i)
            
            if outputGroup?.type() == .eIndicoreOutputGroupCandle
            {
                let indicatorConfiguration = indicatorChartData!.indicatorConfigurations[indicatorConfIndex]
                let outputGroupCandle = outputGroup as! IndicoreOutputGroupCandle
                let priceBarStream = outputGroupCandle.barStream()
                let existingIndicatorItemsCount = UInt(indicatorConfiguration.indicatorItemsCount())
                let lastUpdateIndex = UInt((indicatorInstance?.lastUpdate())!)
                
                if existingIndicatorItemsCount < lastUpdateIndex
                {
                    for j: UInt in existingIndicatorItemsCount..<lastUpdateIndex
                    {
                        let o = priceBarStream?.openPrice(at: j)
                        let c = priceBarStream?.closePrice(at: j)
                        let h = priceBarStream?.highPrice(at: j)
                        let l = priceBarStream?.lowPrice(at: j)
                        let oleDate = storage.date(at: j)
                        let item = IndicatorItem(openPrice: o!, closePrice: c!, lowPrice: l!, highPrice: h!, oleDate: oleDate)
                        indicatorConfiguration.appendItem(indicatorItem: item)
                     }
                }
            }
            else if outputGroup?.type() == .eIndicoreOutputGroupChannel
            {
                let outputGroupChannel = outputGroup as! IndicoreOutputGroupChannel
                let indicatorConfiguration = indicatorChartData!.indicatorConfigurations[indicatorConfIndex]
                let existingIndicatorItemsCount = UInt(indicatorConfiguration.indicatorItemsCount())
                let lastUpdateIndex = UInt((indicatorInstance?.lastUpdate())!)
                
                if existingIndicatorItemsCount < lastUpdateIndex
                {
                    let firstStream = outputGroupChannel.firstStream()
                    let secondStream = outputGroupChannel.secondStream()
                    for j: UInt in existingIndicatorItemsCount..<lastUpdateIndex
                    {
                        var price = firstStream?.price(at: j)
                        var date = firstStream?.date(at: j)
                        var item = IndicatorItem(price: price!, oleDate: date!)
                        indicatorConfiguration.appendItem(indicatorItem: item)
                        
                        price = secondStream?.price(at: j)
                        date = secondStream?.date(at: j)
                        item = IndicatorItem(price: price!, oleDate: date!)
                        indicatorConfiguration.appendItem(indicatorItem: item)
                    }

                }
            }
            indicatorConfIndex += 1
        }
        
        let candlesCount = storage.size()
        if candlesCount == 0
        {
            return false
        }
        
        let chartData = indicatorChartData!.chartData
        let existingChartItemsCount = UInt(chartData.chartItemsCount())
        for i: UInt in existingChartItemsCount..<candlesCount
        {
            let o = storage.bidOpen(at: i)
            let c = storage.bidClose(at: i)
            let h = storage.bidHigh(at: i)
            let l = storage.bidLow(at: i)
            let oleDate = storage.date(at: i)
            let item = ChartItem(open: o,close: c,hight: h,low: l, oleDate: oleDate)
            chartData.appenItem(chartItem: item)
        }
        
        return true
    }

    private func printError(error: NSError)
    {
        var description = "Unknown error: cannot calculate indicatator."
        
        if error.isKind(of: IndicoreError.self) == false
        {
            showError(msg: description)
            return
        }
        
        let indicoreError = error as! IndicoreError
        if indicoreError.size() == 0
        {
            showError(msg: description)
            return
        }
     
        let errorInfo = indicoreError.error(at: 0)
        if let textValue = errorInfo?.text
        {
            description = "Error: "
            description += textValue
            showError(msg: description)
        }
        else
        {
            showError(msg: description)
        }
    }
    
    private func showError(msg: String)
    {
        let errorView = UIAlertView(title: "Error", message: msg, delegate: nil, cancelButtonTitle: "Ok")
        errorView.show()
    }
    
}
