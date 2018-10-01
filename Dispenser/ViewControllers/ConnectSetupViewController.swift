import NetworkExtension
import UIKit
import Drift

class ConnectSetupViewController: PairingViewController {
    @IBOutlet var continueButton: UIButton!

    var service: Sweetrpc_SweetServiceClient?

    @IBAction func connect() {
        self.performSegue(withIdentifier: "next", sender: nil)
    }
    
    @IBAction func needHelp() {
        Drift.showConversations()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.continueButton.isEnabled = false

        let configuration = NEHotspotConfiguration(ssid: "candy", passphrase: "reckless", isWEP: false)
        configuration.joinOnce = true
        NEHotspotConfigurationManager.shared.apply(configuration) { error in
            if error != nil {
                if error?.localizedDescription == "already associated." {
                    self.continueButton.isEnabled = true
                    self.performSegue(withIdentifier: "next", sender: nil)
                }
                else {
                    print("No Connected")
                }
            }
            else {
                self.continueButton.isEnabled = true
                self.performSegue(withIdentifier: "next", sender: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DispenserConnectedViewController {
            let vc = segue.destination as? DispenserConnectedViewController
            vc?.service = Sweetrpc_SweetServiceClient(address: "192.168.27.1:9000", secure: false)
        }
    }
}
