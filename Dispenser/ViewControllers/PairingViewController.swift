import CoreData
import UIKit

class PairingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.dispenser != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(PairingViewController.cancel)
            )
        }
    }
    
    @IBAction func cancel() {
        jumpTo(storyboard: "Main")
    }
}
