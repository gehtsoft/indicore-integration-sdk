import Foundation
import UIKit

class ColorPickerViewController : UIViewController {
    
    private var colorSlider: ColorSlider?
    private var colorValue : UIColor?
    var completionHandler: ((UIColor) -> ())?
    
    public var color:  UIColor? {
        get { return colorValue }
        set { colorValue = newValue }
    }
    
    override func viewDidLoad() {
        colorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
        
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(colorSlider!)
        setupConstraints()
        
        if let colorVal = colorValue {
            colorSlider?.color = colorVal
        } else {
            colorSlider?.color = .white
        }
    }
    
    // Set up view constraints.
    func setupConstraints() {
        let colorSliderHeight = CGFloat(15)
        colorSlider!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorSlider!.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            colorSlider!.rightAnchor.constraint(equalTo: view!.rightAnchor, constant: -20),
            colorSlider!.centerXAnchor.constraint(equalTo: view!.centerXAnchor),
            colorSlider!.centerYAnchor.constraint(equalTo: view!.centerYAnchor),
            colorSlider!.heightAnchor.constraint(equalToConstant: colorSliderHeight),
            ])
    }
    
    @IBAction func onSaveClicked(_ sender: UIButton) {
        color = colorSlider?.color
        if let navigController = navigationController {
            navigController.popViewController(animated: true)
        }
        
        if let complHendler = completionHandler { complHendler(color!) }
    }
    

    @IBAction func onCancelClicked(_ sender: UIButton) {
        if let navigController = navigationController {
            navigController.popViewController(animated: true)
        }
    }
}
