import UIKit

class PairingSucceededViewController: PairingBaseViewController {
    @IBAction func setup(_ sender: LoadingButton) {
        self.coordinator?.showWifiNetworks()
    }
}
