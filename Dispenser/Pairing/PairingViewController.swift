import CoreData
import UIKit

class PairingViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var lastOpenedDispenser: Dispenser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remporary solution, until pairing screens are migrated to coordinators
        self.lastOpenedDispenser = appDelegate.coordinator?.getLastOpenedDispenser()
        
        if lastOpenedDispenser != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(PairingViewController.cancel)
            )
        }
    }
    
    @IBAction func cancel() {
        guard let dispenserToOpen = self.lastOpenedDispenser else {
            return
        }
        
        appDelegate.coordinator?.open(dispenser: dispenserToOpen)
    }
}
