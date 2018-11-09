import UIKit

class PairingInvalidViewController: PairingBaseViewController {
    @IBAction func retry(_ sender: Any) {
        self.coordinator?.retryConnection()
    }
}
