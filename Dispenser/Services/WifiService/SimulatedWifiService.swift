import UIKit

class SimulatedWifiService: WifiService {
    var viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func connect(ssid: String, password: String, completionHandler: ((WifiState) -> Void)?) {
        let alert = UIAlertController(
            title: "Simulated Wi-Fi",
            message: "Should your Wi-Fi connection to «\(ssid)» succeed?",
            preferredStyle: UIAlertController.Style.alert
        )
        
        let succeedAction = UIAlertAction(title: "Succeed", style: .default) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                completionHandler?(.connected)
            }
        }
        
        let failAction = UIAlertAction(title: "Fail", style: .destructive) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                completionHandler?(.failed)
            }
        }
        
        alert.addAction(succeedAction)
        alert.addAction(failAction)
        
        self.viewController.present(alert, animated: true)
    }
    
    func disconnect(ssid: String) {
        let alert = UIAlertController(
            title: "Simulated Wi-Fi",
            message: "Disconnecting from «\(ssid)».",
            preferredStyle: UIAlertController.Style.alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        self.viewController.present(alert, animated: true)
    }
}
