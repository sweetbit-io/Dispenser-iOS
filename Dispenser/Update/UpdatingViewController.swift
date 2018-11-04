import UIKit

class UpdatingViewController: UIViewController, Storyboarded {
    var coordinator: UpdateCoordinator?

    @IBAction func help(_ sender: Any) {
        self.coordinator?.help()
    }
}
