import UIKit
import Drift

class ConnectionFailedSetupViewController: PairingViewController {
    @IBAction func needHelp() {
        Drift.showConversations()
    }
}
