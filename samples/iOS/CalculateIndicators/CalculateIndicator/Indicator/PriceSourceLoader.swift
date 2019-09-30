import Foundation

struct PriceSource
{
    let date: Double
    let bidopen: Double
    let bidhigh: Double
    let bidlow: Double
    let bidclose: Double
    let askopen: Double
    let askhigh: Double
    let asklow: Double
    let askclose: Double
    let volume: Double
    
    init(date: Double, bidopen: Double, bidhigh: Double, bidlow: Double, bidclose: Double, askopen: Double, askhigh: Double, asklow: Double, askclose: Double, volume: Double)
    {
        self.date = date
        self.bidopen = bidopen
        self.bidlow = bidlow
        self.bidhigh = bidhigh
        self.bidclose = bidclose
        self.askopen = askopen
        self.askhigh = askhigh
        self.asklow = asklow
        self.askclose = askclose
        self.volume = volume
    }
}

class PriceSourceLoader
{
    var priceSources: Array<PriceSource>?
    var name: String?
    var timeframe: String?
    var precision: NSInteger?
    var displayprecision: NSInteger?
    var pipSize: Double?
    var supportsVolume: Bool?
    var instrument: String?
    
    let isBarChart: Bool
    
    init(isBarChart: Bool)
    {
        priceSources = Array<PriceSource>()        
        self.isBarChart = isBarChart
    }
    
    func load()
    {
        if isBarChart
        {
            load(historyFileName: Bundle.main.bundlePath + "/history/bars.csv")
        }
        else
        {
            load(historyFileName: Bundle.main.bundlePath + "/history/ticks.csv")
        }
    }
    
    private func load(historyFileName: String)
    {
        let f = fopen(historyFileName,"r")
        let lines = lineGenerator(file: f!)
        for line in lines {
            let lineWoEof: String?
            if line.last == "\n"
            {
                lineWoEof = String(line.dropLast())
            } else {
                lineWoEof = line
            }
            let parts = lineWoEof!.components(separatedBy: ";")
            if parts[0] == "HDR"
            {
                self.pipSize = Double(parts[6])
                self.name = parts[1]
                self.instrument = parts[1]
                self.timeframe = parts[4]
                self.precision = Int(round(-log10(pipSize! / 10.0)) + 0.5)
                self.displayprecision = self.precision
                self.pipSize = Double(parts[6])
                self.supportsVolume = (parts[5] == "1")
     
            }
            else if (parts[0] == "DAT")
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yy HH:mm:ss"
                formatter.timeZone = TimeZone(identifier: "EST")
                let date = formatter.date(from: parts[1])
                let oleTime = IndicoreDateUtils.oleTime(fromNativeTime: date!)?.doubleValue
                
                var volume = 0.0;
                if parts.count > 9
                {
                    if let vol = Double(parts[10])
                    {
                        volume = vol
                    }
                }
                
                let priceSource = PriceSource(date: oleTime!, bidopen: Double(parts[2])!, bidhigh: Double(parts[3])!, bidlow: Double(parts[4])!, bidclose: Double(parts[5])!, askopen: Double(parts[6])!, askhigh: Double(parts[7])!, asklow: Double(parts[8])!, askclose: Double(parts[9])!, volume: volume)
                priceSources?.append(priceSource)
            }
        }
    }
    
    private func lineGenerator(file:UnsafeMutablePointer<FILE>) -> AnyIterator<String>
    {
        return AnyIterator { () -> String? in
            var line:UnsafeMutablePointer<CChar>? = nil
            var linecap:Int = 0
            defer { free(line) }
            return getline(&line, &linecap, file) > 0 ? String.init(validatingUTF8: line!) : nil
        }
    }
}
