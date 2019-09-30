import Foundation
import UIKit

// SingleChartViewController uses one view for drawing an indicator and an instrument chart.
//
class SingleChartViewController : UIViewController, IAxisValueFormatter
{
    var producer: IndicatorChartDataProducer?
    var indicatorChartData: IndicatorChartData?
    
    @IBOutlet weak var chartView: ChartView!    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad()
    {
        title = "Chart"
        
        producer?.subscribeUpdates(callback: indicatorChartDataChanged)
        producer?.startProduceLivePrices() // start emulation of getting life quotes
        
        chartView.xAxis.valueFormatter = self
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // check if the back button was pressed
        if self.isMovingFromParentViewController
        {
            producer?.stopProduceLivePrices() //  stop emulation of getting life quotes
            producer = nil
        }
    }
    
    func indicatorChartDataChanged(indicatorChartData: IndicatorChartData)
    {
        self.indicatorChartData = indicatorChartData
        
        if indicatorChartData.chartData.isCandleChart
        {
            chartView.drawChart(indicatorChartData: indicatorChartData, drawIndicatorOnChart: true)
        }
        else
        {
            chartView.drawChart(indicatorChartData: indicatorChartData, drawIndicatorOnChart: true)
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
}
