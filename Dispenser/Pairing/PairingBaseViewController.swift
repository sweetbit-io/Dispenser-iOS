import UIKit

class PairingBaseViewController: UIViewController, Storyboarded {
    var coordinator: PairingCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.coordinator?.coordinator.getLastOpenedDispenser() != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(PairingBaseViewController.cancel)
            )
        }
    }
    
    @IBAction func cancel() {
        self.coordinator?.cancel()
    }
    
    @IBAction func help() {
        self.coordinator?.help()
    }
}
