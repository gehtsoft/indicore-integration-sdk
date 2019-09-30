import Foundation

// The root object containing data for drawing charts
//
class IndicatorChartData
{
    public let chartData: IndicoreChartData                         // data for drawing an instrument chart
    public let indicatorConfigurations: [IndicatorConfiguration]    // data for drawing an indicator
    public let indicatorName: String
        
    init(chartData: IndicoreChartData, indicatorName: String, indicatorConfigurations:  [IndicatorConfiguration])
    {
        self.indicatorConfigurations = indicatorConfigurations
        self.chartData = chartData
        self.indicatorName = indicatorName
    }
}
