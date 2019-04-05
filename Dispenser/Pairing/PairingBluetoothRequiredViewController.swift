import UIKit

class PairingBluetoothRequiredViewController: PairingBaseViewController {
    @IBAction func startSetup() {
        self.coordinator?.startSetup()
    }
}

