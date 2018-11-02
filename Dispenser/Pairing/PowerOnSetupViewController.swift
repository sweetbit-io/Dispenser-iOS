import UIKit
import Drift

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
