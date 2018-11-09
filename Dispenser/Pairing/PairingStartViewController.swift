import UIKit

class PairingStartViewController: PairingBaseViewController {
    @IBAction func startSetup() {
        self.coordinator?.startSetup()
    }
}
