import UIKit

class StartSetupViewController: PairingViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func startSetup() {
        performSegue(withIdentifier: "next", sender: nil)
    }

    @IBAction func buyDispenser() {
        print("Buy dispenser")
    }
}
