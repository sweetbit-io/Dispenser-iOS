import UIKit

class PairingSucceededViewController: PairingBaseViewController {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func setup(_ sender: LoadingButton) {
        self.coordinator?.configure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator!.peripherialName.bind(to: self.nameLabel.rx.text)
    }
}
