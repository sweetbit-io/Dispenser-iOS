import Drift
import UIKit

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

        WiFiService.connect(ssid: "candy", password: "reckless") {
            switch $0 {
            case .alreadyConnected:
                fallthrough
            case .connected:
                self.continueButton.isEnabled = true
                self.performSegue(withIdentifier: "next", sender: nil)
            default:
                self.continueButton.isEnabled = true
                self.performSegue(withIdentifier: "failed", sender: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DispenserConnectedViewController {
            let vc = segue.destination as? DispenserConnectedViewController
            vc?.service = Sweetrpc_SweetServiceClient(address: "192.168.27.1:9000", secure: false)
        }
    }
}
