import UIKit

class UpdateConnectionFailedViewController: UIViewController, Storyboarded {
    var coordinator: UpdateCoordinator?
    
    @IBAction func retry(_ sender: LoadingButton) {
        self.coordinator?.retryRestart()
    }
    
    @IBAction func help(_ sender: Any) {
        self.coordinator?.help()
    }
}
