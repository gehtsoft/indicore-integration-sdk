import UIKit

class EditDateViewController: UIViewController {
    
    var date: Date?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var completionHandler: ((Date) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dateValue = date {
            datePicker.setDate(dateValue, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        date = datePicker.date
        navigationController?.popViewController(animated: true)
        
        if let complHendler = completionHandler {
            complHendler(date!)
        }
    }
}

