import UIKit

class PowerOnSetupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func connect() {
        performSegue(withIdentifier: "next", sender: nil)
    }

    @IBAction func needHelp() {
        print("Help!")
    }
}
