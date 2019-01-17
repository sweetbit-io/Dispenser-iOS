import UIKit

class PairingUpdateSucceededViewController: PairingBaseViewController {
    @IBAction func reboot(_ sender: LoadingButton) {
        sender.showLoading()
        
        self.coordinator?.doReboot() {
            sender.hideLoading()
        }
    }
}
