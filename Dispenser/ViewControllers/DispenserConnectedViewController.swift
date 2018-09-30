import UIKit

class DispenserConnectedViewController: UIViewController {
    var service: Sweetrpc_SweetServiceClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WifiViewController {
            let vc = segue.destination as? WifiViewController
            vc?.service = self.service
        }
    }
}
