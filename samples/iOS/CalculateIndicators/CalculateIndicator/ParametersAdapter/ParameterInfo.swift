import Foundation

class ParameterInfo
{
    let parameterId: String
    let name: String
    let value: String
    let alternatives: [String]?
    let type: IndicoreParameterType
    let color: UIColor?
    let minValue: String?
    let maxValue: String?
    let isEditable: Bool?
    
    init(name: String, value: String, color: UIColor?, parameterId: String, alternatives: [String]?, type: IndicoreParameterType, minValue: String?, maxValue: String?)
    {
        self.name = name
        
        self.parameterId = parameterId
        self.alternatives = alternatives
        self.type = type
        self.color = color
        self.minValue = minValue
        self.maxValue = maxValue
        
        /* Disable editing for all line style parameters,
           to keep things simple assume one is always 'Solid'
        */
        if name.contains("style")
        {
            isEditable = false
            self.value = "Solid"
        }
        else
        {
            isEditable = true
            self.value = value
        }
    }
}
