import Drift
import UIKit

class WifiViewController: PairingViewController, UITableViewDataSource, UITableViewDelegate {
    var service: Sweetrpc_SweetServiceClient?
    var networks: [Sweetrpc_WpaNetwork]?
    var info: Sweetrpc_GetWpaConnectionInfoResponse?
    var selectedSsid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func needHelp(_ sender: UIButton) {
        Drift.showConversations()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.networks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "networkCell", for: indexPath)
        let network = self.networks![indexPath.row]
        cell.textLabel?.text = network.ssid
        cell.tintColor = UIColor.primary
        
        if self.info?.ssid == network.ssid {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let networks = self.networks {
            let network = networks[indexPath.row]
            
            self.selectedSsid = network.ssid
            
            if self.info?.ssid == network.ssid {
                self.performSegue(withIdentifier: "connected", sender: nil)
            } else {
                self.performSegue(withIdentifier: "next", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WifiAuthViewController {
            let vc = segue.destination as! WifiAuthViewController
            vc.service = self.service
            vc.ssid = self.selectedSsid
        } else if segue.destination is WifiConnectedViewController {
            let vc = segue.destination as! WifiConnectedViewController
            vc.service = self.service
        }
    }
}
