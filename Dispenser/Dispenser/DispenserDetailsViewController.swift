import Drift
import RxSwift
import UIKit

class DispenserDetailsViewController: UITableViewController, Storyboarded {
    var coordinator: DispenserCoordinator?
    var disposeBag = DisposeBag()
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var serialNoLabel: UILabel!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var commitLabel: UILabel!
    
    @IBAction func valueChanged(_ sender: UITextField) {
        guard let name = sender.text else {
            return
        }
        
        if name.isEmpty {
            guard let coordinator = self.coordinator else {
                return
            }
            
            // reset to previous value if field is empty
            sender.text = try? coordinator.name.value()
            return
        }
        
        self.coordinator?.changeName(name: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.serialNoLabel.text = self.coordinator?.dispenser.serial
        self.versionLabel.text = self.coordinator?.dispenser.version
        self.commitLabel.text = self.coordinator?.dispenser.commit
        
        self.hideKeyboardWhenTappedAround()
        
        self.coordinator?.name
            .subscribe(onNext: { name in
                self.nameTextField.text = name
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: name, style: .plain, target: nil, action: nil)
            })
            .disposed(by: self.disposeBag)
    }
    
    @IBAction override func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
