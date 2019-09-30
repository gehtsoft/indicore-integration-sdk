import Foundation

class IndicoreChartData
{
    public let isCandleChart: Bool
    public let instrument: String
    
    private var locker: NSLock
    private var chartItems: [ChartItem]

    init(instrument: String, chartItems: [ChartItem], isBarChart: Bool)
    {
        self.chartItems = chartItems
        self.isCandleChart = isBarChart
        self.instrument = instrument
        self.locker = NSLock()
    }
    
    func appenItem(chartItem: ChartItem)
    {
        locker.lock()
        chartItems.append(chartItem)
        locker.unlock()
    }
    
    func chartItem(index: Int) -> ChartItem
    {
        locker.lock()
        let item = chartItems[index]
        locker.unlock()
        
        return item
    }
    
    func chartItemsCount() -> Int
    {
        locker.lock()
        let count = chartItems.count
        locker.unlock()
        
        return count
    }
}
