import Foundation

class TerminalTest : IndicoreTerminal
{
}

class HostTest : IndicoreBaseHost
{
    let terminalTest = TerminalTest()
    
    override func name() -> String?
    {
        return "HostTest"
    }
    
    override func version() -> String?
    {
        return "1.0"
    }
    
    override func terminal() throws -> IndicoreTerminal {
        return terminalTest
    }
}
