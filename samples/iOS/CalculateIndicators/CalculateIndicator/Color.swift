import UIKit

extension UIColor
{
    var redValue: Int{ return Int(CIColor(color: self).red * 255) }
    var greenValue: Int{ return Int(CIColor(color: self).green * 255) }
    var blueValue: Int{ return Int(CIColor(color: self).blue * 255) }
    
    var rgbString: String { return "RGB(\(redValue), \(greenValue), \(blueValue))" }
}
