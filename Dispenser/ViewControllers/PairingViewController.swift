import CoreData
import UIKit

class PairingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetch: NSFetchRequest<Dispenser> = Dispenser.fetchRequest()
        
        let dispensers = try! context.fetch(fetch) as [Dispenser]
        
        if dispensers.count > 0 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(PairingViewController.cancel)
            )
        }
    }
    
    @IBAction func cancel() {
        jumpTo(storyboard: "Main")
    }
}
