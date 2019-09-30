import Foundation
import UIKit

class StatisticViewController : UITableViewController
{
    var indicatorChartData: IndicatorChartData?
    var firstIndicatorConfiguration: IndicatorConfiguration?
    var count: Int?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "First indicator's stream"
        firstIndicatorConfiguration = indicatorChartData!.indicatorConfigurations[0]
        count = firstIndicatorConfiguration?.indicatorItemsCount()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return count!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.text = firstIndicatorConfiguration?.indicatorItem(index: indexPath.row).date
        var price: Double = (firstIndicatorConfiguration?.indicatorItem(index: indexPath.row).closePrice)!
        price = Double(round(100000*price)/100000)
        cell.detailTextLabel?.text = "\(price)"
        return cell
    }
}































