import UIKit

class UpdateRestartingViewController: UIViewController, Storyboarded {
    var coordinator: UpdateCoordinator?

    @IBAction func help(_ sender: Any) {
        self.coordinator?.help()
    }
}
