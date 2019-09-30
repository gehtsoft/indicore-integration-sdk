import Foundation
import UIKit

class PropertyViewController : UITableViewController, UIAlertViewDelegate
{
    var indicatorProfile: IndicoreIndicatorProfile
    {
        get
        {
            return profile!
        }
        set
        {
            profile = newValue
        }
    }
    
    private var profile: IndicoreIndicatorProfile?
    private var parametersAdapter: ParametersAdapter?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = profile?.name()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Run indicator", style: .plain, target: self, action: #selector(runIndicator))
        
        parametersAdapter = ParametersAdapter(params: (profile?.parameters())!)
    }

    
    // Load price sources from a file and calculate the indicator
    @objc func runIndicator()
    {
        let router = ChartViewControllersRouter(profile: profile!, parametersAdapter: parametersAdapter!, parentViewController: self)
        router?.route()
    }
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedParameter = parametersAdapter?.parameter(groupIndex: indexPath.section, parameterIndex: indexPath.row)
        if selectedParameter?.isEditable == false
        {
            return
        }
        let type = selectedParameter?.type
        
        if type! == IndicoreParameterType.eIndicoreIntegerType ||
            type! == IndicoreParameterType.eIndicoreDoubleType ||
            type! == IndicoreParameterType.eIndicoreFileType ||
            type! == IndicoreParameterType.eIndicoreStringType
        {
            editNumberOrString(param: selectedParameter!, type: type!)
        }
        else if type! == IndicoreParameterType.eIndicoreBooleanType
        {
            editBoolean(param: selectedParameter!)
        }
        else if type == IndicoreParameterType.eIndicoreColorType
        {
            editColor(param: selectedParameter!)
        }
        else if type == IndicoreParameterType.eIndicoreColorType
        {
            editColor(param: selectedParameter!)
        }
        else if type == IndicoreParameterType.eIndicoreDateType
        {
            editDate(param: selectedParameter!)
        }
    }
    
    // edit functions
    
    func  editAlternatives(param: ParameterInfo)
    {
        let controller = storyboard?.instantiateViewController(withIdentifier: "EditAlternativesController") as! EditAlternativesController
        controller.value = param.value
        controller.alternatives = param.alternatives
        controller.completionHandler = { (value: String) in
            let isOk = self.parametersAdapter?.setStringOrNumber(newValue: value, parameterInfo: param)
            self.showErrorIfNeed(isNeed: isOk!)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func editBoolean(param: ParameterInfo)
    {
        let controller = storyboard?.instantiateViewController(withIdentifier: "EditAlternativesController") as! EditAlternativesController
        controller.value = param.value
        controller.alternatives = ["true", "false"]
        controller.completionHandler = { (value: String) in
            let isOk = self.parametersAdapter?.setStringOrNumber(newValue: value, parameterInfo: param)
            self.showErrorIfNeed(isNeed: isOk!)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func editDate(param: ParameterInfo)
    {
        let controller = storyboard?.instantiateViewController(withIdentifier: "EditDateViewController") as! EditDateViewController
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd hh:mm:ss"
        controller.date = formatter.date(from: param.value)
        controller.completionHandler = { (value: Date) in
            self.parametersAdapter?.setDate(newDate: value, parameterInfo: param)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func editColor(param: ParameterInfo)
    {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ColorPickerViewController") as! ColorPickerViewController
        controller.color = param.color
        controller.completionHandler = { (color: UIColor) in
            self.parametersAdapter?.setColor(newColor: color, parameterInfo: param)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func editNumberOrString(param: ParameterInfo, type: IndicoreParameterType)
    {
        if param.alternatives == nil
        {
            let controller = storyboard?.instantiateViewController(withIdentifier: "EditStringOrNumberController") as! EditStringOrNumberController
            controller.valueType = type
            controller.value = param.value
            controller.minValue = param.minValue
            controller.maxValue = param.maxValue
            controller.completionHandler = { (value: String) in
                let isOk = self.parametersAdapter?.setStringOrNumber(newValue: value, parameterInfo: param)
                self.showErrorIfNeed(isNeed: isOk!)
                self.tableView.reloadData()
            }
            navigationController?.pushViewController(controller, animated: true)
        }
        else
        {
           editAlternatives(param: param)
        }
    }
    
    func showErrorIfNeed(isNeed: Bool)
    {
        if isNeed == false
        {
            let alert = UIAlertView()
            alert.message = "Cannot set new value"
            alert.addButton(withTitle: "OK")
            alert.show()
        }
    }
}
