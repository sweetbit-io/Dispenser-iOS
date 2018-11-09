import UIKit

class PairingUnreachableViewController: PairingBaseViewController {
    @IBAction func retry(_ sender: Any) {
        self.coordinator?.retryConnection()
    }
}
