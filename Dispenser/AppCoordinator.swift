import CoreData
import Drift
import RxSwift
import UIKit

class AppCoordinator {
    var window: UIWindow?
    var pairingCoordinator: PairingCoordinator?
    var dispenserCoordinator: DispenserCoordinator?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let lastOpenedDispenser = self.getLastOpenedDispenser()
        
        var viewControllerToSet: UIViewController?
        
        if let dispenserToOpen = lastOpenedDispenser {
            dispenserToOpen.lastOpened = Date()
            AppDelegate.shared.saveContext()
            
            self.dispenserCoordinator = DispenserCoordinator(coordinator: self, dispenser: dispenserToOpen)
            self.dispenserCoordinator?.start()
            
            viewControllerToSet = self.dispenserCoordinator?.navigationController
        } else {
            self.pairingCoordinator = PairingCoordinator(coordinator: self)
            self.pairingCoordinator?.start()
            
            viewControllerToSet = self.pairingCoordinator?.navigationController
        }
        
        self.window?.rootViewController = viewControllerToSet
    }
    
    func getLastOpenedDispenser() -> Dispenser? {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let fetch: NSFetchRequest<Dispenser> = Dispenser.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "lastOpened", ascending: false)]
        
        let dispensers = try? context.fetch(fetch) as [Dispenser]
        
        return dispensers?.first
    }
    
    func getDispensers() -> [Dispenser] {
        let context = AppDelegate.shared.persistentContainer.viewContext
        let fetch: NSFetchRequest<Dispenser> = Dispenser.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "lastOpened", ascending: false)]
        
        let dispensers = try? context.fetch(fetch) as [Dispenser]
        
        return dispensers ?? []
    }
    
    func open(dispenser: Dispenser) {
        dispenser.lastOpened = Date()
        AppDelegate.shared.saveContext()
        
        self.dispenserCoordinator = DispenserCoordinator(coordinator: self, dispenser: dispenser)
        self.dispenserCoordinator?.start()
        
        // Leads to nice animation
        self.dispenserCoordinator?.navigationController.view.frame = self.window!.rootViewController!.view.frame
        self.dispenserCoordinator?.navigationController.view.layoutIfNeeded()
        
        UIView.transition(with: self.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = self.dispenserCoordinator?.navigationController
        }, completion: { _ in
            self.pairingCoordinator = nil
        })
    }
    
    func pairNewDispenser() {
        self.pairingCoordinator = PairingCoordinator(coordinator: self)
        self.pairingCoordinator?.start()
        
        // Leads to nice animation
        self.pairingCoordinator?.navigationController.view.frame = self.window!.rootViewController!.view.frame
        self.pairingCoordinator?.navigationController.view.layoutIfNeeded()
        
        UIView.transition(with: self.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = self.pairingCoordinator?.navigationController
        }, completion: { _ in
            self.dispenserCoordinator = nil
        })
    }
    
    func unpair(dispenser: Dispenser) {
        let context = AppDelegate.shared.persistentContainer.viewContext
        context.delete(dispenser)
        
        var viewControllerToPresent: UIViewController?
        
        if let dispenserToOpen = self.getLastOpenedDispenser() {
            self.dispenserCoordinator = DispenserCoordinator(coordinator: self, dispenser: dispenserToOpen)
            self.dispenserCoordinator?.start()
            viewControllerToPresent = self.dispenserCoordinator?.navigationController
        } else {
            self.pairingCoordinator = PairingCoordinator(coordinator: self)
            self.pairingCoordinator?.start()
            viewControllerToPresent = self.pairingCoordinator?.navigationController
        }
        
        // Leads to nice animation
        viewControllerToPresent?.view.frame = self.window!.rootViewController!.view.frame
        viewControllerToPresent?.view.layoutIfNeeded()
        
        UIView.transition(with: self.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = viewControllerToPresent
        }, completion: { _ in
            self.dispenserCoordinator = nil
        })
    }
    
    func help() {
        Drift.showConversations()
    }
}
