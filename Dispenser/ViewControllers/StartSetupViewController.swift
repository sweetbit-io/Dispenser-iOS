import UIKit
import Drift

class StartSetupViewController: PairingViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func startSetup() {
        performSegue(withIdentifier: "next", sender: nil)
    }

    @IBAction func buyDispenser() {
        Drift.showConversations()
    }
}
