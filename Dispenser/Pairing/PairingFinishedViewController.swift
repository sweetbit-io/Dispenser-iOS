import UIKit

class PairingFinishedViewController: PairingBaseViewController {
    @IBAction func start(_ sender: UIButton) {
        self.coordinator?.finishPairing()
    }
}
