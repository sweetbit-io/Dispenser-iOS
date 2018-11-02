import RxSwift
import UIKit

class DispenserCoordinator {
    var coordinator: AppCoordinator
    var remoteNodeCoordinator: RemoteNodeCoordinator?
    var updateCoordinator: UpdateCoordinator?
    var navigationController: DispenserNavigationController
    var dispenser: Dispenser
    var client: Sweetrpc_SweetServiceClient?
    
    var latestRelease = BehaviorSubject<Release?>(value: nil)
    var version = BehaviorSubject<String?>(value: nil)
    var updateAvailable: Observable<Bool>
    var remoteNodeUrl = BehaviorSubject<String?>(value: nil)
    
    init(coordinator: AppCoordinator, dispenser: Dispenser) {
        self.navigationController = DispenserNavigationController.instantiate()
        self.dispenser = dispenser
        self.coordinator = coordinator
        
        self.version.onNext(self.dispenser.version)
        
        self.updateAvailable = Observable.combineLatest(
            self.version, self.latestRelease, resultSelector: { version, release in
                print("Update available? Current: \(version ?? "-") Available: \(release?.version ?? "-")")
                
                guard let version = version else {
                    return false
                }
                
                guard let release = release else {
                    return false
                }
                
                return isVersion(release.version, higherThan: version)
            }
        )
    }
    
    func start() {
        guard let ip = self.dispenser.ip else {
            self.showNoConnection()
            return
        }
        
        let address = String(format: "%@:%d", ip, 9000)
        self.client = Sweetrpc_SweetServiceClient(address: address, secure: false)
        
        let req = Sweetrpc_GetInfoRequest()
        
        guard let client = self.client else {
            self.showNoConnection()
            return
        }
        
        guard let info = try? client.getInfo(req) else {
            self.showNoConnection()
            return
        }
        
        print("Got remote node \(info.remoteNode.uri)")
        
        if info.remoteNode.uri != "" {
            self.remoteNodeUrl.onNext(info.remoteNode.uri)
        }
        
        // TODO: enable this as soon as it's safe to update
        // GetLatestRelease { self.latestRelease.onNext($0) }
        
        let vc = MainTableViewController.instantiate()
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: false)
    }
    
    func showNoConnection() {
        let vc = NoConnectionViewController.instantiate()
        vc.coordinator = self
        
        self.navigationController.setViewControllers([vc], animated: true)
    }
    
    func retryConnection() {
        // just call start again
        self.start()
    }
    
    func showUpdate() {
        guard let release = (try? self.latestRelease.value()) ?? nil else {
            return
        }
        
        self.updateCoordinator = UpdateCoordinator(coordinator: self, release: release)
        self.updateCoordinator?.start()
        
        self.navigationController.present((self.updateCoordinator?.navigationController)!, animated: true)
    }
    
    func toggleDispenseOnTouch(enable: Bool) {
    }
    
    func toggleBuzzOnDispense(enable: Bool) {
    }
    
    func connectRemoteNode() {
        self.remoteNodeCoordinator = RemoteNodeCoordinator(coordinator: self)
        self.remoteNodeCoordinator?.start()
        
        self.navigationController.present((self.remoteNodeCoordinator?.navigationController)!, animated: true)
    }
    
    func disconnectRemoteNode() {
        let alert = UIAlertController(
            title: "Disconnect",
            message: "This will stop dispensing candy for incoming payments through the currently connected node. You can re-connect anytime again.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        let disconnectAction = UIAlertAction(title: "Disconnect", style: .destructive, handler: { _ in
            let req = Sweetrpc_DisconnectFromRemoteNodeRequest()
            
            _ = try? self.client?.disconnectFromRemoteNode(req)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(disconnectAction)
        alert.addAction(cancelAction)
        
        self.navigationController.present(alert, animated: true, completion: nil)
    }
    
    func unpair() {
        let alert = UIAlertController(
            title: "Unpair",
            message: "This will drop the connection to the dispenser, but still keep it running. You can pair anytime again.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        let unpairAction = UIAlertAction(
            title: "Unpair", style: .destructive, handler: { _ in
                self.coordinator.unpair(dispenser: self.dispenser)
            }
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(unpairAction)
        alert.addAction(cancelAction)
        
        self.navigationController.present(alert, animated: true, completion: nil)
    }
    
    func addDispenser() {
        self.coordinator.pairNewDispenser()
    }
    
    func switchDispenser() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let dispensers = self.coordinator.getDispensers()
        
        for dispenser in dispensers {
            // Don't display currently opened dispenser
            if self.dispenser == dispenser {
                continue
            }
            
            let action = UIAlertAction(title: dispenser.serial, style: .default) { _ in
                self.coordinator.open(dispenser: dispenser)
            }
            
            optionMenu.addAction(action)
        }
        
        // Show option for pairing a new dispenser
        let addAction = UIAlertAction(title: "Add a new candy dispenser...", style: .default) { _ in
            self.coordinator.pairNewDispenser()
        }
        
        // Color the option differently
        addAction.setValue(UIColor.darkText, forKey: "titleTextColor")
        
        optionMenu.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        self.navigationController.present(optionMenu, animated: true, completion: nil)
    }
    
    func help() {
        self.coordinator.help()
    }
}

func isVersion(_ version: String, higherThan: String) -> Bool {
    return version.compare(higherThan, options: .numeric) == .orderedDescending
}

func isVersion(_ version: String, higherOrEqual: String) -> Bool {
    switch version.compare(higherOrEqual, options: .numeric) {
    case .orderedDescending:
        return true
    case .orderedSame:
        return true
    default:
        return false
    }
}
