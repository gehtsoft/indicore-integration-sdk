import Foundation

//  The Level line
class LevelLine
{
    let y: Double         // level lines have only the Y coordinate according to which they are drawn along the X axis.
    let width: Int
    let style: IndicoreLineStyle
    let color: UIColor
    
    init(y: Double, width: Int, style: IndicoreLineStyle, color: UIColor)
    {
        self.y = y
        self.width = width
        self.style = style
        self.color = color
    }
}
