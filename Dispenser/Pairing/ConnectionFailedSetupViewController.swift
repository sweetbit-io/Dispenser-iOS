import Drift
import UIKit

class ConnectionFailedSetupViewController: PairingViewController {
    @IBAction func needHelp() {
        Drift.showConversations()
    }
}
