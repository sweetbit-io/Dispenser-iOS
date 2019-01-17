import UIKit

class PairingUpdateAvailableViewController: PairingBaseViewController {
    @IBAction func update(_ sender: LoadingButton) {
        sender.showLoading()
        
        self.coordinator?.doUpdate() {
            sender.hideLoading()
        }
    }
}
