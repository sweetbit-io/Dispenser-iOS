import UIKit
import Drift

let defaultBottomConstraint: CGFloat = 20

class WifiAuthViewController: PairingViewController {
    var service: Sweetrpc_SweetServiceClient?
    var ssid: String?
    
    @IBOutlet var password: UITextField!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var formView: UIView!
    @IBOutlet var connectButton: LoadingButton!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WifiAuthViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.connectButton.isEnabled = self.password.text?.count ?? 0 >= 8
        self.titleLabel.text = "Connect to " + (self.ssid ?? "Wi-Fi network")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.password.becomeFirstResponder()
    }
    
    @IBAction func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        bottomConstraint.constant = keyboardSize - self.view.safeAreaInsets.bottom + defaultBottomConstraint
        
        let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    @IBAction func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraint.constant = defaultBottomConstraint
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    @IBAction override func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        self.connectButton.isEnabled = sender.text?.count ?? 0 >= 8
    }
    
    @IBAction func connect(_ sender: LoadingButton) {
        sender.showLoading()
        
        let ssid = self.ssid ?? ""
        let psk = self.password.text ?? ""
        
        DispatchQueue.global(qos: .background).async {
            var req = Sweetrpc_ConnectWpaNetworkRequest()
            req.ssid = ssid
            req.psk = psk
            
            let res = try? self.service?.connectWpaNetwork(req) ?? nil
            
            DispatchQueue.main.async {
                if res == nil {
                    sender.hideLoading()
                } else if res!!.status == .connected {
                    sender.hideLoading()
                    self.performSegue(withIdentifier: "connected", sender: nil)
                } else if res!!.status == .failed {
                    sender.hideLoading()
                    self.password.shake()
                }
            }
        }
    }
    
    @IBAction func needHelp(_ sender: UIButton) {
        Drift.showConversations()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WifiConnectedViewController {
            let vc = segue.destination as! WifiConnectedViewController
            vc.service = self.service
        }
    }
}