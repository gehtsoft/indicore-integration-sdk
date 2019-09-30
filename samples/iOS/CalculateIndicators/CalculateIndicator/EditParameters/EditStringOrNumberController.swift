import Foundation
import UIKit

class EditStringOrNumberController : UIViewController, UITextFieldDelegate
{
    var value: String?
    var minValue: String?
    var maxValue: String?
    var valueType: IndicoreParameterType?
    var completionHandler: ((String) -> ())?
    
    @IBOutlet weak var desciptionField: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let val = value
        {
            textField.text = val
        }
        
        if minValue != nil && maxValue != nil
        {
            desciptionField.text = desciptionField.text! + "(min \(minValue!), max \(maxValue!))"
        }
        else if minValue != nil
        {
            desciptionField.text = desciptionField.text! + "(min \(minValue!))"
        }
        else if maxValue != nil
        {
            desciptionField.text = desciptionField.text! + "(max \(maxValue!))"
        }
        
        textField.delegate = self;
        textField.becomeFirstResponder()
    }
    
    @IBAction func OnCancel(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSave(_ sender: UIButton)
    {
        var isGood = false
        
        if let text = textField.text
        {
            if Int(text) != nil && valueType == IndicoreParameterType.eIndicoreIntegerType
            {
                isGood = validateInt(text: text)
            }
            else if Double(text) != nil && valueType == IndicoreParameterType.eIndicoreDoubleType
            {
                isGood = validateDouble(text: text)
            }
            else if valueType == IndicoreParameterType.eIndicoreStringType || valueType == IndicoreParameterType.eIndicoreFileType
            {
                isGood = true
            }
                
                
            if isGood == true
            {
                value = text
                navigationController?.popViewController(animated: true)
                if let complHendler = completionHandler { complHendler(value!) }
            }
            else
            {
                let errorView = UIAlertView(title: "Error", message: "Value did not pass validation", delegate: nil, cancelButtonTitle: "Ok")
                errorView.show()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validateInt(text: String) -> Bool
    {
        var min: Int? = Int.min
        var max: Int? = Int.max
        
        if minValue != nil
        {
            min = Int(minValue!)
        }
        
        if maxValue != nil
        {
            max = Int(maxValue!)
        }
        
        let val = Int(text)
        
        if val == nil
        {
            return false
        }
        
        return val! >= min! && val! <= max!
    }
    
    func validateDouble(text: String) -> Bool 
    {
        var min: Double? = Double.leastNormalMagnitude
        var max: Double? = Double.greatestFiniteMagnitude
        
        if minValue != nil
        {
            min = Double(minValue!)
        }
        
        if maxValue != nil
        {
            max = Double(maxValue!)
        }
        
        let val = Double(text)
        
        if val == nil
        {
            return false
        }
        
        return val! >= min! && val! <= max!
    }
}











