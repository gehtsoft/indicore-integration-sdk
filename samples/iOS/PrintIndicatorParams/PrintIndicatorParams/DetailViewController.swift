import Foundation
import UIKit

class DetailViewController : UITableViewController, UIAlertViewDelegate
{
    private var profile: IndicoreIndicatorProfile?
    private var parametersAdapter: ParametersAdapter?
    
    var indicatorProfile: IndicoreIndicatorProfile
    {
        get { return profile! }
        set { profile = newValue }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = profile?.name()
        
        parametersAdapter = ParametersAdapter(params: (profile?.parameters())!)
    }
    
    // MARK: - tableview

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        let count = parametersAdapter?.groupsCount
        return count!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let count = parametersAdapter?.elementsCountInGroup(groupIndex: section)
        return count!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        
        let parameterInfo = parametersAdapter?.parameter(groupIndex: indexPath.section, parameterIndex: indexPath.row)
        
        if let paramInfo = parameterInfo
        {
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            /* show color as colored square */
            if let color = paramInfo.color
            {
                cell.textLabel?.text = paramInfo.name
                let coloredView = UIView(frame: CGRect(x: cell.frame.width, y: 0, width: 40, height: cell.frame.height))
                coloredView.backgroundColor = color
                cell.addSubview(coloredView)
            }
            else
            {
                cell.textLabel?.text = paramInfo.name + " = " + paramInfo.value
                
                /* show detailed button if paramer has alternatves */
                cell.accessoryType = paramInfo.alternatives == nil ?
                    UITableViewCellAccessoryType.none :
                    UITableViewCellAccessoryType.detailDisclosureButton
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return parametersAdapter?.groupName(groupIndex: section)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        let parameterInfo = parametersAdapter?.parameter(groupIndex: indexPath.section, parameterIndex: indexPath.row)
        
        if let paramInfo = parameterInfo
        {
            if let alternatives = paramInfo.alternatives
            {
                var text = "Indicator '\(paramInfo.name)' has alternatives:\n"
                text += (alternatives.joined(separator: "\n"))
                
                let alert = UIAlertView()
                alert.message = text
                alert.addButton(withTitle: "OK")
                alert.show()
            }
        }
    }
}
