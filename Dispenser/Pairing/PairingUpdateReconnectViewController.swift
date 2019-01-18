import UIKit

class PairingUpdateReconnectViewController: PairingBaseViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.coordinator?.interruptConnection()
        }
    }
    
    @IBAction func reconnect(_ sender: LoadingButton) {
        sender.showLoading()
        sender.isEnabled = false
        
        self.coordinator?.connect() { status in
            sender.hideLoading()
            sender.isEnabled = true
            
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
