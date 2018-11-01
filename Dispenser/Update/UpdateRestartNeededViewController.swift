import UIKit

class UpdateRestartNeededViewController: UIViewController, Storyboarded {
    var coordinator: UpdateCoordinator?
    
    @IBAction func restart(_ sender: LoadingButton) {
        sender.showLoading()
        
        self.coordinator?.restart()
    }
}
