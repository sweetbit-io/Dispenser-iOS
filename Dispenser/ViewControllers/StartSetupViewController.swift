import UIKit
import LGButton

class StartSetupViewController: UIViewController {

    @IBOutlet weak var button: LGButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.button.bgColor = UIColor.primary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func startSetup() {
        performSegue(withIdentifier: "next", sender: nil)
    }

    @IBAction func buyDispenser(_ sender: UIButton) {
        print("Buy dispenser")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
