import Foundation


enum IndicatorConfigurationType
{
    case ICTypeBar
    case ICTypeCandle
    case ICTypeLine
    case ICTypeDot
}

// One element of the indicator chart: a line, a candle chart, or a histogram.
//
class IndicatorConfiguration
 {
    public let color: UIColor?
    public let lineWidth: Int
    public let lineStyle: IndicoreLineStyle
    public let type: IndicatorConfigurationType
    public let levels: [LevelLine]?
    
    public let isChannel: Bool
    
    private var indicatorItems: [IndicatorItem]
    private var locker: NSLock
    
    var hasLivelLines: Bool
    {
        get { return levels != nil }
    }
    
    init(indicatorItems: [IndicatorItem], color: UIColor?, lineWidth: Int, lineStyle: IndicoreLineStyle, type: IndicatorConfigurationType, isChannel: Bool, levels: [LevelLine]?)
     {
        self.indicatorItems = indicatorItems
        self.color = color
        self.lineWidth = lineWidth
        self.lineStyle = lineStyle
        self.type = type
        self.isChannel = isChannel
        self.levels = levels
        self.locker = NSLock()
     }
    
    func appendItem(indicatorItem: IndicatorItem)
    {
        locker.lock()
        indicatorItems.append(indicatorItem)
        locker.unlock()
    }
    
    func indicatorItem(index: Int) -> IndicatorItem
    {
        locker.lock()
        let item = indicatorItems[index]
        locker.unlock()
        
        return item
    }
    
    func indicatorItemsCount() -> Int
    {
        locker.lock()
        let count = indicatorItems.count
        locker.unlock()
        
        return count
    }
 }
