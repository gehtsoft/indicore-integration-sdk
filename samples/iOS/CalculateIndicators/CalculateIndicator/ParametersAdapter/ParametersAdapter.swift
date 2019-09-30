import Foundation

class ParametersAdapter
{
    let params: IndicoreParameters
    var groupOfParameters: [ParameterGroupInfo]
    
    var groupsCount: Int
    {
        get { return groupOfParameters.count }
    }
    
    init(params: IndicoreParameters)
    {
        self.groupOfParameters = ParametersAdapterHelper.fillData(parameters: params)
        self.params = params;
    }

    func parameter(groupIndex: Int, parameterIndex: Int) -> ParameterInfo?
    {
        return ParametersAdapterHelper.parameter(parameterGroups: groupOfParameters, groupIndex: groupIndex, parameterIndex: parameterIndex)
    }
    
    func groupName(groupIndex: Int) -> String?
    {
        return ParametersAdapterHelper.group(groupOfParameters: groupOfParameters, groupIndex: groupIndex)?.groupName
    }
    
    func elementsCountInGroup(groupIndex: Int) -> Int
    {
        let group = ParametersAdapterHelper.group(groupOfParameters: groupOfParameters, groupIndex: groupIndex)
        return group!.parameters.count
    }
    
    func setStringOrNumber(newValue: String?, parameterInfo: ParameterInfo) -> Bool
    {
        let paramId = parameterInfo.parameterId
        let param = params.parameter(withId: paramId).value()
        let type = param?.type()
        var result = false
        
        switch type! {
        case .eIndicoreBooleanType:
            param?.setBoolean(newValue! == "true")
            result = true
            break
        case .eIndicoreIntegerType:
            let newNumber = Int(newValue!)
            if let newNumberValue = newNumber {
                param?.setInteger(newNumberValue)
                result = true
            }
            break
        case .eIndicoreDoubleType:
            let newNumber = Double(newValue!)
            if let newNumberValue = newNumber {
                param?.setDouble(newNumberValue)
                result = true
            }
            break
        case .eIndicoreStringType:
            param?.setString(newValue!)
            result = true
            break
        case .eIndicoreFileType:
            param?.setFile(newValue!)
            result = true
            break
        default: break
        }
        
        self.groupOfParameters = ParametersAdapterHelper.fillData(parameters: params)
        
        return result
    }
    
    func setColor(newColor: UIColor, parameterInfo: ParameterInfo)
    {
        let paramId = parameterInfo.parameterId
        let param = params.parameter(withId: paramId).value()
        param?.setColor(newColor)
       
        self.groupOfParameters = ParametersAdapterHelper.fillData(parameters: params)
    }
    
    func setDate(newDate: Date, parameterInfo: ParameterInfo)
    {
        let paramId = parameterInfo.parameterId
        let param = params.parameter(withId: paramId).value()
        let oleDate = IndicoreDateUtils.oleTime(fromNativeTime: newDate)
        param?.setDate((oleDate?.doubleValue)!)
        
        self.groupOfParameters = ParametersAdapterHelper.fillData(parameters: params)
    }

}
