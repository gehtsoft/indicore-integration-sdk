import Foundation

class ChartItem
{
    public let open: Double
    public let close: Double
    public let hight: Double
    public let low: Double
    public let date: String
    public let smallDate: String
        
    init(open: Double, close: Double, hight: Double, low: Double, oleDate: Double)
    {
        self.open = open
        self.close = close
        self.hight = hight
        self.low = low
        
        let cocoaDate = IndicoreDateUtils.nativeTime(fromOleTime: oleDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm:SS"
        formatter.timeZone = TimeZone(identifier: "UTC")
        self.date = formatter.string(from: cocoaDate!)
        
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        self.smallDate = formatter.string(from: cocoaDate!)
    }
}
