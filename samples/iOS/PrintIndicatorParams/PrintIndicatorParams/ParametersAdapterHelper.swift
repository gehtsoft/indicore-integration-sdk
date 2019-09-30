import Foundation

/* Class contains utility functions */
class ParametersAdapterHelper
{
    static let dateFormatterString = "yyyy.MM.dd hh:mm:ss"
    
    static func grabString(param: IndicoreParameterConstant) -> String?
    {
        var value: String?
        
        switch param.type()
        {
        case IndicoreParameterType.eIndicoreNillType:
            value = "Nil"
            break
        case IndicoreParameterType.eIndicoreBooleanType:
            value = param.booleanValue() == true ? "true" : "false"
            break
        case IndicoreParameterType.eIndicoreIntegerType:
            value = String(param.intValue())
            break
        case IndicoreParameterType.eIndicoreDoubleType:
            value = String(param.doubleValue())
            break
        case IndicoreParameterType.eIndicoreStringType:
            value = param.stringValue()
            break
        case IndicoreParameterType.eIndicoreDateType:
            let oleDate = param.dateValue()
            value = ParametersAdapterHelper.parseDate(oleDate: oleDate, isNil: param.isNil())
            break
        case IndicoreParameterType.eIndicoreFileType:
            value = param.fileValue();
            break
        case IndicoreParameterType.eIndicoreColorType:
            let valueColor = param.colorValue()
            if let valColor = valueColor
            {
                value = valColor.rgbString
            }
            else
            {
                return nil
            }
            break
        default:
            value = "";
            break
        }
        
        return value
    }
    
    static func parseDate(cocoaDateAsString: String) -> Double?
    {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatterString
        let date = formatter.date(from: cocoaDateAsString)
        let oleTime = IndicoreDateUtils.oleTime(fromNativeTime: date!)
        return oleTime?.doubleValue
    }
    
    private static func parseDate(oleDate: Double, isNil: Bool) -> String
    {
        if oleDate == 0 && isNil == true
        {  // nil
            return "Nil by default"
        }
        
        // use EST time
        if oleDate == 0 && isNil == false
        { // current date
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = dateFormatterString
            return formatter.string(from: Date())
        }
        
        // if oleDate less than zero => oleDate is offset from current date
        if (oleDate < 0)
        {
            var offset = DateComponents()
            offset.day = Int(oleDate)
            let calendar = Calendar.current
            let localDateWithOffset = calendar.date(byAdding: offset, to: Date())
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = dateFormatterString
            return formatter.string(from: localDateWithOffset!)
        }
        
        // oleTime use EST by default
        let date = IndicoreDateUtils.nativeTime(fromOleTime: oleDate)
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatterString
        return formatter.string(from: date!)
    }
    
    /* Get data from IndicoreParameters and returns it as ParameterGroupInfo */
    static func fillData(parameters: IndicoreParameters) -> [ParameterGroupInfo]
    {
        var parameterGroups = [ParameterGroupInfo]()
        let groups = parameters.groups()
        for var i: UInt in 0..<(groups?.size())!
        {
            var paramsValue = [ParameterInfo]()
            let group = groups?.group(at: i)
            let groupName = group?.name()
            for var j : UInt in 0..<(group?.size())!
            {
                let parameter = group?.parameter(at: j)
                let minValue = ParametersAdapterHelper.grabString(param: (parameter?.minimalValue())!)
                let maxValue = ParametersAdapterHelper.grabString(param: (parameter?.maximalValue())!)
                let parameterName = parameter?.name()!
                let parameterType = parameter?.value()?.type()
                var color : UIColor? = nil
                if parameterType == IndicoreParameterType.eIndicoreColorType
                {
                    color = (parameter?.value()?.colorValue())!
                }
                let parameterId = parameter?.identifier()
                let parameterStringValue = ParametersAdapterHelper.grabString(param: parameter!.value()!)
                let alternativesStringValues = fillAlternatives(parameter: parameter!)
                let paramValue = ParameterInfo(name: parameterName!, value: parameterStringValue!, color: color, parameterId: parameterId!, alternatives: alternativesStringValues, type: parameterType!, minValue: minValue, maxValue: maxValue)
                paramsValue.append(paramValue)
            }
            let groupValue = ParameterGroupInfo(groupName: groupName!, parameters: paramsValue)
            parameterGroups.append(groupValue)
        }
        
        return parameterGroups
    }
    
    /* return all parametr alternatives as array of string */
    private static func fillAlternatives(parameter: IndicoreParameter) -> [String]?
    {
        var alternativesValues: [String]?
        if parameter.hasAlternatives()
        {
            alternativesValues = [String]()
            let alternatives = parameter.alternatives()
            let alternativesSize = alternatives?.size()
            for var j : UInt in 0..<alternativesSize!
            {
                let alternative = alternatives?.alternative(at: j)
                let value = alternative?.value()
                let alternativeStr = grabString(param: value!)
                alternativesValues?.append(alternativeStr!)
            }
        }
        return alternativesValues
    }
    
    /* Utility function to get ParameterInfo from array of ParameterGroupInfo */
    static func parameter(parameterGroups: [ParameterGroupInfo], groupIndex: Int, parameterIndex: Int) -> ParameterInfo?
    {
        if groupIndex >= parameterGroups.count
        {
            return nil
        }
        
        let group = parameterGroups[groupIndex]
        
        if parameterIndex >= group.parameters.count
        {
            return nil
        }
        
        return group.parameters[parameterIndex]
    }
    
    /* Utility function to get ParameterGroupInfo from array of ParameterGroupInfo */
    static func group(groupOfParameters: [ParameterGroupInfo], groupIndex: Int) -> ParameterGroupInfo?
    {
        if groupIndex >= groupOfParameters.count
        {
            return nil
        }
        
        return groupOfParameters[groupIndex]
    }
}
