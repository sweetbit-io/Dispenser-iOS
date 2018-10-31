import CoreData
import NetworkExtension
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
        
        guard let service = self.service else {
            print("No service available")
            return
        }
        
        let req = Sweetrpc_GetInfoRequest()
        
        print("Calling getInfo")
        
        guard let info = try? service.getInfo(req) else {
            print("Got invalid response for getInfo")
            return
        }
        
        let connectionInfoReq = Sweetrpc_GetWpaConnectionInfoRequest()
        
        print("Calling getInfo")
        
        guard let connectionInfo = try? service.getWpaConnectionInfo(connectionInfoReq) else {
            print("Got invalid response for getWpaConnectionInfo")
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
            dispenserToOpen?.ip = connectionInfo.ip
            dispenserToOpen?.lastOpened = Date()
            appDelegate.saveContext()
        } else {
            print("Dispenser is new. Creating and opening it...")
            dispenserToOpen = Dispenser(context: context)
            dispenserToOpen?.serial = info.serial
            dispenserToOpen?.version = info.version
            dispenserToOpen?.commit = info.commit
            dispenserToOpen?.ip = connectionInfo.ip
            dispenserToOpen?.lastOpened = Date()
            appDelegate.saveContext()
        }
        
        appDelegate.dispenser = dispenserToOpen
        
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: "candy")
        
        jumpTo(storyboard: "Main")
    }
    
    @IBAction func needHelp(_ sender: UIButton) {
        Drift.showConversations()
    }
}
