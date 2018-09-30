import UIKit

let defaultBottomConstraint: CGFloat = 20

class WifiAuthViewController: UIViewController {
    @IBOutlet var password: UITextField!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var formView: UIView!
    @IBOutlet var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formView.addTopBorderWithColor(color: UIColor.lightGray, width: 1)
        self.formView.addBottomBorderWithColor(color: UIColor.lightGray, width: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WifiAuthViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.connectButton.isEnabled = self.password.text?.count ?? 0 >= 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.password.becomeFirstResponder()
    }
    
    @IBAction func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        bottomConstraint.constant = keyboardSize - self.view.safeAreaInsets.bottom + defaultBottomConstraint
        
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    @IBAction func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraint.constant = defaultBottomConstraint
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    @IBAction func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        self.connectButton.isEnabled = sender.text?.count ?? 0 >= 8
    }
    
    @IBAction func connect(_ sender: UIButton) {
        print(self.password.text ?? "")
    }
}
