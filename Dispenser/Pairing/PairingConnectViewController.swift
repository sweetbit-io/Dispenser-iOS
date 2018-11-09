import RxSwift
import UIKit

class PairingConnectViewController: PairingBaseViewController {
    @IBOutlet var connectButton: LoadingButton!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.coordinator?.interruptConnection()
        }
    }
    
    @IBAction func connect() {
        self.connectButton.showLoading()
        self.connectButton.isEnabled = false
        
        self.coordinator?.connect() { status in
            self.connectButton.hideLoading()
            self.connectButton.isEnabled = true
            
            switch status {
            case .connected:
                self.coordinator?.showConnectionSucceeded()
            case .invalid:
                self.coordinator?.showConnectionInvalid()
            case .unreachable:
                self.coordinator?.showConnectionUnreachable()
            }
        }
    }
}
