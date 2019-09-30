import Foundation
import UIKit

// Oscillators are drawn on a separate view, the other types of indicators are drawn on the same view as the instrument chart
// ChartViewControllersRouter allows instantiating the appropriate controller for the current indicator type (with one or two views)
//
class ChartViewControllersRouter
{
    let chartViewController: UIViewController
    let parentViewController: UIViewController
    
    init?(profile: IndicoreIndicatorProfile, parametersAdapter: ParametersAdapter, parentViewController: UIViewController)
    {
        self.parentViewController = parentViewController
        let producer = IndicatorChartDataProducer(profile: profile, parameters: parametersAdapter.params)
        if producer != nil
        {
            // draw the indicator and the chart
    
            let storyboard = parentViewController.storyboard!
            
            if (producer?.isIndicatorDrawOnMainChart)!
            {
                let singleChartViewController = storyboard.instantiateViewController(withIdentifier: "SingleChartViewController") as! SingleChartViewController
                singleChartViewController.producer = producer
                chartViewController = singleChartViewController
            }
            else
            {
                let doubleChartViewController = storyboard.instantiateViewController(withIdentifier: "DoubleChartsViewController") as! DoubleChartsViewController
                doubleChartViewController.producer = producer
                chartViewController = doubleChartViewController
            }
        }
        else
        {
            return nil
        }
    }
    
    func route()
    {
        let navigationController = parentViewController.navigationController!
        navigationController.pushViewController(chartViewController, animated: true)
    }
    
    
    
}
