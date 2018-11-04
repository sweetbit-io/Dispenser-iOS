import Drift
import UIKit

class PowerOnSetupViewController: PairingViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func connect() {
        performSegue(withIdentifier: "next", sender: nil)
    }

    @IBAction func needHelp() {
        Drift.showConversations()
    }
}
