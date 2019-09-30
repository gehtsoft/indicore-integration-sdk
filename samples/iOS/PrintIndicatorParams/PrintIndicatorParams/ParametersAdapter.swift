import Foundation

/* Simple Parameter adapter: help us get information about one */
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
    
     // MARK: - getters

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
}
