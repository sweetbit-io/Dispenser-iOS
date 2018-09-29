import UIKit

class PairingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(PairingViewController.cancel)
        )
    }

    @IBAction func cancel() {
        jumpTo(storyboard: "Main")
    }
}
