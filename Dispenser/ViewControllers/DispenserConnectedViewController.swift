import UIKit
import Drift

class DispenserConnectedViewController: PairingViewController {
    var service: Sweetrpc_SweetServiceClient?
    var networks: [Sweetrpc_WpaNetwork]?
    var info: Sweetrpc_GetWpaConnectionInfoResponse?
    @IBOutlet var setupButton: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func needHelp(_ sender: UIButton) {
        Drift.showConversations()
    }
    
    @IBAction func setup(_ sender: UIButton) {
        self.setupButton.showLoading()
        
        DispatchQueue.global(qos: .background).async {
            let networks = self.getNetworks()
            let info = self.getNetworkInfo()
            
            DispatchQueue.main.async {
                self.networks = networks
                self.info = info
                
                self.setupButton.hideLoading()
                self.performSegue(withIdentifier: "setup", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WifiViewController {
            let vc = segue.destination as! WifiViewController
            vc.service = self.service
            vc.networks = self.networks
            vc.info = self.info
        }
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
