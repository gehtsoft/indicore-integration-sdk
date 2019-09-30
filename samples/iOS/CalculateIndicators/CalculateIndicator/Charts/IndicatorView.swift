import Foundation
import UIKit

// The view where a chart for an indicator is drawn.
//
class IndicatorView : CombinedChartView
{
    private var levelsData: [LineChartDataSet]?
    
    var indicatorConfigurations: [IndicatorConfiguration]?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setChartProperties()
        levelsData = [LineChartDataSet]()
    }
    
    func setChartProperties()
    {
        self.maxVisibleCount = 15;
        self.pinchZoomEnabled = false
        self.drawGridBackgroundEnabled = false
        self.legend.enabled = false
        self.chartDescription?.enabled = false
        
        self.xAxis.enabled = false
        
        let leftAxis = self.leftAxis
        leftAxis.labelCount = 7
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        
        let rightAxis = self.rightAxis
        rightAxis.enabled = false
        
        isUserInteractionEnabled = false
    }
    
    func drawIndicator(indicatorConfigurations: [IndicatorConfiguration])
    {
        self.indicatorConfigurations = indicatorConfigurations
        levelsData!.removeAll()
        
        if indicatorConfigurations.isEmpty
        {
            self.clear()
            return
        }
        
        let combinedData = CombinedChartData()
        
        let indicatorData = getLineDataSet()
        combinedData.barData = getBarDataSet()
        combinedData.lineData = LineChartData(dataSets: indicatorData)
        for levelData in levelsData!
        {
            combinedData.lineData.addDataSet(levelData)
        }
        combinedData.candleData = getCandleData()
        
        self.data = combinedData
        self.setNeedsDisplay()
    }

    func getLineDataSet() -> [IChartDataSet]
    {
        var lineDataSets = [LineChartDataSet]()
        for indicatorConfiguration in indicatorConfigurations!
        {
            if indicatorConfiguration.type == .ICTypeLine || indicatorConfiguration.type == .ICTypeDot
            {
                var index = 0
                var entries = [ChartDataEntry]()
                let indicatorItemsCount = indicatorConfiguration.indicatorItemsCount()
                for i in 0..<indicatorItemsCount
                {
                    let indicatorItem = indicatorConfiguration.indicatorItem(index: i)
                    if indicatorItem.closePrice != 0
                    {
                        entries.append(ChartDataEntry(x: Double(index), y: indicatorItem.closePrice))
                    }
                    index += 1
                }
                
                let lineDataSet = LineChartDataSet(values: entries, label: nil)
                lineDataSet.setColor(indicatorConfiguration.color!)
                lineDataSet.lineWidth = CGFloat(indicatorConfiguration.lineWidth)
                lineDataSet.drawValuesEnabled = false
                lineDataSet.drawCirclesEnabled = false
                lineDataSets.append(lineDataSet)
                
                fillLevelsData(indicatorConfiguration: indicatorConfiguration, entries: entries)

                /*if indicatorConfiguration.isChannel
                {
                 // A channel is a filled area between two lines.
                 // The Swift Charts Framework does not support drawing of channels.
                }*/
                
                /*if indicatorConfiguration.type == .StreamTypeDot
                {
                 // The Swift Charts Framework does not support dotted lines.
                }*/
            }
        }
        return lineDataSets
    }

    func getBarDataSet() -> BarChartData
    {
        let barChartData = BarChartData()
        
        for indicatorConfiguration in indicatorConfigurations!
        {
            if indicatorConfiguration.type == .ICTypeBar
            {
                var index = 0
                var entries = [BarChartDataEntry]()
                let indicatorItemsCount = indicatorConfiguration.indicatorItemsCount()
                
                for i in 0..<indicatorItemsCount
                {
                    let indicatorItem = indicatorConfiguration.indicatorItem(index: i)
                    if indicatorItem.closePrice != 0
                    {
                        entries.append(BarChartDataEntry(x: Double(index), y: indicatorItem.closePrice))
                    }
                    index += 1
                }
                
                let barChartDataSet = BarChartDataSet(values: entries, label: nil)
                barChartDataSet.setColor(indicatorConfiguration.color!)
                barChartData.addDataSet(barChartDataSet)
                
                fillLevelsData(indicatorConfiguration: indicatorConfiguration, entries: entries)
            }
        }
        return barChartData
    }
    
    func getCandleData() -> CandleChartData
    {
        let candleData = CandleChartData()
        
        for indicatorConfiguration in indicatorConfigurations!
        {
            if indicatorConfiguration.type == .ICTypeCandle
            {
                var index = 0
                let indicatorItemsCount = indicatorConfiguration.indicatorItemsCount()
                var candleEnties = [CandleChartDataEntry]()
                for i in 0..<indicatorItemsCount
                {
                    let h = indicatorConfiguration.indicatorItem(index: i).highPrice
                    let l = indicatorConfiguration.indicatorItem(index: i).lowPrice
                    let c = indicatorConfiguration.indicatorItem(index: i).closePrice
                    let o = indicatorConfiguration.indicatorItem(index: i).openPrice
                    
                    let candleChartItem = CandleChartDataEntry(x: Double(index), shadowH: h!, shadowL: l!, open: o!, close: c)
                    index += 1
                    candleEnties.append(candleChartItem)
                }
                let candleDataSet = CandleChartDataSet(values: candleEnties, label: nil)
                
                candleDataSet.setColor(UIColor.black)
                candleDataSet.shadowColor = UIColor.darkGray
                candleDataSet.shadowWidth = 1
                candleDataSet.decreasingColor = UIColor.red
                candleDataSet.decreasingFilled = true
                candleDataSet.increasingColor = UIColor(displayP3Red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
                candleDataSet.increasingFilled = true
                candleDataSet.neutralColor = UIColor.white
                candleDataSet.valueTextColor = UIColor.red
                candleData.addDataSet(candleDataSet)
            }
        }
        return candleData
    }
    
    func fillLevelsData(indicatorConfiguration: IndicatorConfiguration, entries: [ChartDataEntry])
    {
        if indicatorConfiguration.hasLivelLines
        {
            let levelsCount = indicatorConfiguration.levels!.count
            for i in 0..<levelsCount
            {
                let level = indicatorConfiguration.levels![i]
                var levelEntries = [ChartDataEntry]()
                for j in 0..<entries.count
                {
                    levelEntries.append(ChartDataEntry(x: entries[j].x, y: level.y))
                }
                let lineDataSet = LineChartDataSet(values: levelEntries, label: nil)
                lineDataSet.setColor(level.color)
                lineDataSet.lineWidth = CGFloat(level.width)
                lineDataSet.drawValuesEnabled = false
                lineDataSet.drawCirclesEnabled = false
                levelsData!.append(lineDataSet)
            }
        }
    }
}
