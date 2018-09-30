import UIKit

class WifiConnectedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func start(_ sender: UIButton) {
        jumpTo(storyboard: "Main")
    }
}
