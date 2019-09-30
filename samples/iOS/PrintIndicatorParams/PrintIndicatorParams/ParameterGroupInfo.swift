import Foundation

/* Simple ParameterGroup wrapper */
class ParameterGroupInfo {
    public let groupName: String
    public let parameters : [ParameterInfo]
    
    init(groupName: String, parameters: [ParameterInfo])
    {
        self.groupName = groupName
        self.parameters = parameters
    }
}

