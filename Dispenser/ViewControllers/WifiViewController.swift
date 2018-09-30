import UIKit

class WifiViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var service: Sweetrpc_SweetServiceClient?
    var networks: [Sweetrpc_WpaNetwork]?
    var info: Sweetrpc_GetWpaConnectionInfoResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.networks = getNetworks()
        self.info = getNetworkInfo()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
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
        self.performSegue(withIdentifier: "next", sender: nil)
    }
    
    func getNetworks() -> [Sweetrpc_WpaNetwork]? {
        let req = Sweetrpc_GetWpaNetworksRequest()
        let res = try? self.service?.getWpaNetworks(req)
        
        return res??.networks
    }
    
    func getNetworkInfo() -> Sweetrpc_GetWpaConnectionInfoResponse? {
        let req = Sweetrpc_GetWpaConnectionInfoRequest()
        let res = try? self.service?.getWpaConnectionInfo(req)
        
        return res ?? nil
    }
}
