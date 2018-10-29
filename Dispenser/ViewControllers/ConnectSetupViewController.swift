import Drift
import NetworkExtension
import UIKit
import SystemConfiguration.CaptiveNetwork

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

        print("View did load")

        self.continueButton.isEnabled = false
        
        let configuration = NEHotspotConfiguration(ssid: "candy", passphrase: "reckless", isWEP: false)
        configuration.joinOnce = true
        
        NEHotspotConfigurationManager.shared.apply(configuration) { error in
            if error != nil {
                if error?.localizedDescription == "already associated." {
                    // already connected to WiFi
                    self.continueButton.isEnabled = true
                    self.performSegue(withIdentifier: "next", sender: nil)
                } else {
                    // connection failed
                    self.continueButton.isEnabled = true
                    self.performSegue(withIdentifier: "failed", sender: nil)
                }
            } else {
                if self.isConnectedToSsid(ssid: "candy") {
                    // connection succeeded
                    self.continueButton.isEnabled = true
                    self.performSegue(withIdentifier: "next", sender: nil)
                } else {
                    // not connected to WiFi for some reason
                    self.continueButton.isEnabled = true
                    self.performSegue(withIdentifier: "failed", sender: nil)
                }
            }
        }
    }
    
    func isConnectedToSsid(ssid: String) -> Bool {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return false
        }
        
        for interfaceName in interfaceNames {
            guard let info = CNCopyCurrentNetworkInfo(interfaceName as CFString) as? [String:AnyObject] else {
                continue
            }
            
            guard let connectedSsid = info[kCNNetworkInfoKeySSID as String] as? String else {
                continue
            }
            
            return connectedSsid == ssid
        }
        
        return false
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
