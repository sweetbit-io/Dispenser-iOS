import UIKit
import LGButton

class PowerOnSetupViewController: UIViewController {

    @IBOutlet weak var button: LGButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.button.bgColor = UIColor.primary
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
