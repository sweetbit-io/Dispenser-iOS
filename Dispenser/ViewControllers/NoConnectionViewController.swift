import UIKit

class NoConnectionViewController: UIViewController, Storyboarded {
    var coordinator: DispenserCoordinator?
    
    @IBAction func pairAgain(_ sender: Any) {
        self.coordinator?.addDispenser()
    }
    
    @IBAction func retry(_ sender: LoadingButton) {
        sender.showLoading()
        self.coordinator?.retryConnection()
    }
}
