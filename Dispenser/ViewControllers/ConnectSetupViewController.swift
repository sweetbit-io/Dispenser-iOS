import UIKit
// import NetworkExtension

class ConnectSetupViewController: PairingViewController {
    @IBAction func connect() {
        jumpTo(storyboard: "Main")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        let configuration = NEHotspotConfiguration.init(ssid: "candy dispenser", passphrase: "fast candy", isWEP: false)
//        configuration.joinOnce = true
//        NEHotspotConfigurationManager.shared.apply(configuration) { (error) in
//            if error != nil {
//                if error?.localizedDescription == "already associated."
//                {
//                    print("Connected")
//                }
//                else{
//                    print("No Connected")
//                }
//            }
//            else {
//                print("Connected")
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
