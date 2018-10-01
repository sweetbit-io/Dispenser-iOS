import CoreData
import Drift
import UIKit

class WifiConnectedViewController: PairingViewController {
    var service: Sweetrpc_SweetServiceClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func start(_ sender: UIButton) {
        print("Finished pairing")
        
        var dispenserToOpen: Dispenser?
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Could not get app delegate")
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let req = Sweetrpc_GetInfoRequest()
        
        guard let service = self.service else {
            print("No service available")
            return
        }
        
        print("Calling getInfo")
        
        guard let info = try? service.getInfo(req) else {
            print("Got invalid response for getInfo")
            return
        }
        
        let fetch: NSFetchRequest<Dispenser> = Dispenser.fetchRequest()
        
        fetch.predicate = NSPredicate(format: "serial == %@", info.serial)
        
        let dispensers = try? context.fetch(fetch) as [Dispenser]
        
        if let dispenser = dispensers?.first {
            print("Dispenser already exists. Opening it...")
            dispenserToOpen = dispenser
            dispenserToOpen?.serial = info.serial
            dispenserToOpen?.version = info.version
            dispenserToOpen?.commit = info.commit
            dispenserToOpen?.lastOpened = Date()
            appDelegate.saveContext()
        } else {
            print("Dispenser is new. Creating and opening it...")
            dispenserToOpen = Dispenser(context: context)
            dispenserToOpen?.serial = info.serial
            dispenserToOpen?.version = info.version
            dispenserToOpen?.commit = info.commit
            dispenserToOpen?.lastOpened = Date()
            appDelegate.saveContext()
        }
        
        appDelegate.dispenser = dispenserToOpen
        
        jumpTo(storyboard: "Main")
    }
    
    @IBAction func needHelp(_ sender: UIButton) {
        Drift.showConversations()
    }
}
