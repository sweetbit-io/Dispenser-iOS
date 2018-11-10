import UIKit

let defaultBottomConstraint: CGFloat = 20

class PairingWifiAuthViewController: PairingBaseViewController {
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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PairingWifiAuthViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.connectButton.isEnabled = self.password.text?.count ?? 0 >= 8
        
        if let ssid = self.ssid {
            self.titleLabel.text = "Connect to «\(ssid)»"
        } else {
            self.titleLabel.text = "Connect to Wi-Fi network"
        }
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
        guard let ssid = self.ssid else {
            self.password.shake()
            return
        }
        
        sender.showLoading()
        
        self.coordinator?.connectToWifi(ssid: ssid, password: self.password.text) { status in
            if status == .connected {
                sender.hideLoading()
                self.coordinator?.showFinished()
            } else {
                sender.hideLoading()
                self.password.shake()
            }
        }
    }
}
