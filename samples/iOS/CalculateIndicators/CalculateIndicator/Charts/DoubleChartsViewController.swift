import Foundation
import UIKit

// DoubleChartsViewController uses two different views for drawing an oscillator and an instrument chart.
//
class DoubleChartsViewController : UIViewController, IAxisValueFormatter
{
    var producer: IndicatorChartDataProducer?
    var indicatorChartData: IndicatorChartData?
    
    @IBOutlet weak var chartView: ChartView!           // A view for an instrument chart
    @IBOutlet weak var indicatorView: IndicatorView!   // A view for an oscillator
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad()
    {
        title = "Chart"
        
        producer?.subscribeUpdates(callback: indicatorChartDataChanged)
        producer?.startProduceLivePrices()   // start emulation of getting life quotes
        
        chartView.xAxis.valueFormatter = self
        chartView.onRedraw = translateIndicatorsChart // Synchronizing moving and zooming animation between the ChartView and the IndicatorView
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // check if the back button has been clicked
        if self.isMovingFromParentViewController
        {
            producer?.stopProduceLivePrices()  // stop emulation of getting life quotes
            producer = nil
            chartView.onRedraw = nil
        }
    }
    
    func indicatorChartDataChanged(indicatorChartData: IndicatorChartData)
    {
        self.indicatorChartData = indicatorChartData
        
        if indicatorChartData.chartData.isCandleChart  // if the drawn chart is a candle chart
        {
            chartView.drawChart(indicatorChartData: indicatorChartData, drawIndicatorOnChart: false)
            indicatorView.drawIndicator(indicatorConfigurations: indicatorChartData.indicatorConfigurations)
        }
        else
        {
            chartView.drawChart(indicatorChartData: indicatorChartData, drawIndicatorOnChart: false)
            indicatorView.drawIndicator(indicatorConfigurations: indicatorChartData.indicatorConfigurations)
        }
        
        if (descriptionLabel.text == "")
        {
            descriptionLabel.text = "\((indicatorChartData.indicatorName))"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Table", style: .plain, target: self, action: #selector(viewCalcultedDataAsTable))
        }
    }
    
    @objc func viewCalcultedDataAsTable()
    {
        let statisticViewController = storyboard?.instantiateViewController(withIdentifier: "StatisticViewController") as! StatisticViewController
        statisticViewController.indicatorChartData = indicatorChartData
        navigationController?.pushViewController(statisticViewController, animated: true)
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        let position = Int(value)
        if position >= (indicatorChartData?.chartData.chartItemsCount())!
        {
            return ""
        }
        return indicatorChartData!.chartData.chartItem(index: position).smallDate
    }
    
    // Synchronizing moving and zooming animation between the ChartView and the IndicatorView
    func translateIndicatorsChart()
    {
        let currentMatrix = chartView.viewPortHandler.touchMatrix
        indicatorView.viewPortHandler.refresh(newMatrix: currentMatrix, chart: indicatorView, invalidate: true)
    }
}
