import Foundation
import UIKit

// The view where a chart for an instrument is drawn.
// ChartView is inherited from IndicatorView which allows drawing a chart for an instrument and a chart for an indicator on one view if necessary.
//
class ChartView : IndicatorView
{
    var indicatorChartData: IndicatorChartData?
    var onRedraw: (()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setChartProperties()
    }
    
    override func setChartProperties()
    {
        self.maxVisibleCount = 15;
        self.pinchZoomEnabled = false
        self.drawGridBackgroundEnabled = false
        self.legend.enabled = false
        self.chartDescription?.enabled = false
        
        let xAxis = self.xAxis;
        xAxis.labelPosition = XAxis.LabelPosition.bottom
        xAxis.drawGridLinesEnabled = false
        
        let leftAxis = self.leftAxis
        leftAxis.labelCount = 7
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        
        let rightAxis = self.rightAxis
        rightAxis.enabled = false
    }
    
    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        if let onRedrawValue = onRedraw
        {
            onRedrawValue() // Synchronizing moving and zooming animation between the ChartView and the IndicatorView
        }
    }
    
    // Draws a chart for an instrument based on the data of IndicatorChartData.
    // drawIndicatorOnChart defines whether it is necessary to draw the indicator on the same view.
    // Note: Oscillators are drawn on a separate view, the other kinds of indicators are drawn on the same view as the chart.
    func drawChart(indicatorChartData: IndicatorChartData, drawIndicatorOnChart: Bool)
    {
        self.indicatorChartData = indicatorChartData
        self.indicatorConfigurations = indicatorChartData.indicatorConfigurations
        
        if indicatorChartData.chartData.isCandleChart
        {
            buildBarSourceChart(candleChartDataEntries: getCandleEntries(), drawIndicatorOnChart: drawIndicatorOnChart)
        }
        else
        {
            buildTickSourceChart(lineDataSet: getCloseLinearDataSet(), drawIndicatorOnChart: drawIndicatorOnChart)
        }
    }
    
    func buildBarSourceChart(candleChartDataEntries: [CandleChartDataEntry], drawIndicatorOnChart: Bool)
    {
        if candleChartDataEntries.isEmpty
        {
            self.clear()
            return
        }
        
        let combinedData = CombinedChartData()
        let candleChartDataSet = getCandleDataSet(entries: candleChartDataEntries)
        
        if drawIndicatorOnChart == true
        {
            let indicatorData = getLineDataSet()
            combinedData.barData = getBarDataSet()
            combinedData.lineData = LineChartData(dataSets: indicatorData)
            combinedData.candleData = getCandleData()
            combinedData.candleData.addDataSet(candleChartDataSet)
        }
        else
        {
            combinedData.candleData = CandleChartData(dataSet: candleChartDataSet)
        }
        
        self.data = combinedData
        self.setNeedsDisplay()
    }
    
    func buildTickSourceChart(lineDataSet: LineChartDataSet, drawIndicatorOnChart: Bool)
    {
        let combinedData = CombinedChartData()
        
        if drawIndicatorOnChart == true
        {
            let indicatorData = getLineDataSet()
            combinedData.barData = getBarDataSet()
            combinedData.lineData = LineChartData(dataSets: indicatorData)
            combinedData.lineData.addDataSet(lineDataSet)
            combinedData.candleData = getCandleData()
        }
        else
        {
            let lineData = LineChartData()
            lineData.addDataSet(lineDataSet)
            combinedData.lineData = lineData
        }
        
        self.data = combinedData
        self.setNeedsDisplay()
    }
    
    func getCandleEntries() -> [CandleChartDataEntry]
    {
        var candleEnties = [CandleChartDataEntry]()
        
        var index = 0
        let chartItemsCount = indicatorChartData?.chartData.chartItemsCount()
        for i in 0..<chartItemsCount!
        {
            let chartItem = indicatorChartData?.chartData.chartItem(index: i)
            let candleChartItem = CandleChartDataEntry(x: Double(index), shadowH: chartItem!.hight, shadowL: chartItem!.low, open: chartItem!.open, close: chartItem!.close)
            index += 1
            candleEnties.append(candleChartItem)
        }
        return candleEnties
    }
    
    func getCandleDataSet(entries: [CandleChartDataEntry]) -> CandleChartDataSet
    {
        let candleDataSet = CandleChartDataSet(values: entries, label: nil)
        candleDataSet.setColor(UIColor.black)
        candleDataSet.shadowColor = UIColor.darkGray
        candleDataSet.shadowWidth = 1
        candleDataSet.decreasingColor = UIColor.red
        candleDataSet.decreasingFilled = true
        candleDataSet.increasingColor = UIColor(displayP3Red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
        candleDataSet.increasingFilled = true
        candleDataSet.neutralColor = UIColor.blue
        candleDataSet.valueTextColor = UIColor.red
        return candleDataSet;
    }
    
    func getCloseLinearDataSet() -> LineChartDataSet
    {
        var lineEntries = [ChartDataEntry]()
        
        var index = 0
        let chartItemsCount = indicatorChartData?.chartData.chartItemsCount()
        for i in 0..<chartItemsCount!
        {
            let chartItem = indicatorChartData?.chartData.chartItem(index: i)
            let lineChartItem = ChartDataEntry(x: Double(index), y: chartItem!.close)
            index += 1
            lineEntries.append(lineChartItem)
        }
        
        let lineDataSet = LineChartDataSet(values: lineEntries, label: nil)
        lineDataSet.setColor(.black)
        lineDataSet.drawCirclesEnabled = false;
        return lineDataSet
    }
}
