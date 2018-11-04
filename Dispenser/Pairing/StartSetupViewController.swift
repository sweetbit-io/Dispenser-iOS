import Drift
import UIKit

class StartSetupViewController: PairingViewController, Storyboarded {
    var coordinator: PairingCoordinator?

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
