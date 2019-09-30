import Foundation

class IndicatorItem
{
    let closePrice: Double
    let openPrice: Double?
    let lowPrice: Double?
    let highPrice: Double?
    let date: String
    let smallDate: String
    
    let isBar: Bool
    
    init(price: Double, oleDate: Double)
    {
        self.openPrice = nil
        self.closePrice = price
        self.lowPrice = nil
        self.highPrice = nil
        self.isBar = false
        self.date = IndicatorItem.parseDate(oleDate: oleDate)
        self.smallDate = IndicatorItem.parseDateAsSmallDate(oleDate: oleDate)
    }
    
    init(openPrice: Double, closePrice: Double, lowPrice: Double, highPrice: Double, oleDate: Double)
    {
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lowPrice = lowPrice
        self.highPrice = highPrice
        self.isBar = true
        self.date = IndicatorItem.parseDate(oleDate: oleDate)
        self.smallDate = IndicatorItem.parseDateAsSmallDate(oleDate: oleDate)
    }
    
    private static func parseDate(oleDate: Double) -> String
    {
        let cocoaDate = IndicoreDateUtils.nativeTime(fromOleTime: oleDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm:SS"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: cocoaDate!)
    }
    
    private static func parseDateAsSmallDate(oleDate: Double) -> String
    {
        let cocoaDate = IndicoreDateUtils.nativeTime(fromOleTime: oleDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: cocoaDate!)
    }
}
