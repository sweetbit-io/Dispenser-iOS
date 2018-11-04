import RMessage
import RxSwift
import UIKit

enum DispenserState {
    case connected
    case unreachable
    case dispensing
}

class DispenserCoordinator {
    var coordinator: AppCoordinator
    var remoteNodeCoordinator: RemoteNodeCoordinator?
    var updateCoordinator: UpdateCoordinator?
    var navigationController: DispenserNavigationController
    var dispenser: Dispenser
    var client: Sweetrpc_SweetServiceClient?
    var subscribeDispensesCall: Sweetrpc_SweetSubscribeDispensesCall?
    var connected = BehaviorSubject<Bool>(value: false)
    var dispensing = BehaviorSubject<Bool>(value: false)
    var state: Observable<DispenserState>
    let rControl = RMController()
    
    var disposeBag = DisposeBag()
    
    var latestRelease = BehaviorSubject<Release?>(value: nil)
    var updateAvailable: Observable<Bool>
    var remoteNodeUrl = BehaviorSubject<String?>(value: nil)
    
    var name: BehaviorSubject<String>
    var version: BehaviorSubject<String>
    var dispenseOnTouch: BehaviorSubject<Bool>
    var buzzOnDispense: BehaviorSubject<Bool>
    
    init(coordinator: AppCoordinator, dispenser: Dispenser) {
        self.navigationController = DispenserNavigationController.instantiate(fromStoryboard: "Dispenser")
        self.dispenser = dispenser
        self.coordinator = coordinator
        
        // Subjects to push dispenser info changes into
        self.name = BehaviorSubject<String>(value: self.dispenser.name ?? "")
        self.version = BehaviorSubject<String>(value: self.dispenser.version ?? "0.0.0")
        self.dispenseOnTouch = BehaviorSubject<Bool>(value: self.dispenser.dispenseOnTouch)
        self.buzzOnDispense = BehaviorSubject<Bool>(value: self.dispenser.buzzOnDispense)
        
        // Indicator, whether an update is available
        self.updateAvailable = Observable.combineLatest(
            self.version, self.latestRelease, resultSelector: { version, release in
                guard let release = release else {
                    return false
                }
                
                return isVersion(release.version, higherThan: version)
            }
        )
        
        self.state = Observable
            .combineLatest(self.connected, self.dispensing) { connected, dispensing in
                if dispensing {
                    return .dispensing
                } else if connected {
                    return .connected
                } else {
                    return .unreachable
                }
            }
        
        // Persist changes on dispenser info changes
        Observable
            .combineLatest(self.name, self.version, self.dispenseOnTouch, self.buzzOnDispense)
            .subscribe(
                onNext: { name, version, dispenseOnTouch, buzzOnDispense in
                    print("\(name), \(version), \(dispenseOnTouch), \(buzzOnDispense)")
                    
                    self.dispenser.name = name
                    self.dispenser.version = version
                    self.dispenser.dispenseOnTouch = dispenseOnTouch
                    self.dispenser.buzzOnDispense = buzzOnDispense
                    
                    AppDelegate.shared.saveContext()
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    func start() {
        if let ip = self.dispenser.ip {
            let address = String(format: "%@:%d", ip, 9000)
            let client = Sweetrpc_SweetServiceClient(address: address, secure: false)
            
            let req = Sweetrpc_GetInfoRequest()
            
            if let info = try? client.getInfo(req) {
                // Notify potential name change
                self.name.onNext(info.name)
                
                // Notify potential version change
                if !info.version.isEmpty { // TODO: remove this
                    self.version.onNext(info.version)
                }
                
                // Notify settings
                self.dispenseOnTouch.onNext(info.dispenseOnTouch)
                self.buzzOnDispense.onNext(info.buzzOnDispense)
                
                if info.remoteNode.uri != "" {
                    self.remoteNodeUrl.onNext(info.remoteNode.uri)
                }
                
                // save client
                self.client = client
                
                self.subscribeDispenses()
                
                // set connected
                self.connected.onNext(true)
            } else {
                self.showNoConnectionAlert()
            }
        } else {
            // for some strange reason, dispenser has no IP
            self.coordinator.unpair(dispenser: self.dispenser)
            return
        }
        
        // Fetch latest available release
        GetLatestRelease { self.latestRelease.onNext($0) }
        
        let vc = DispenserViewController.instantiate(fromStoryboard: "Dispenser")
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: false)
    }
    
    func subscribeDispenses() {
        guard let client = self.client else {
            return
        }
        
        // Subscribe to dispense events
        let req = Sweetrpc_SubscribeDispensesRequest()
        
        let subscribeDispensesCall = try! client.subscribeDispenses(
            req, completion: {
                print("Completed subscription \($0)")
            }
        )
        
        DispatchQueue.global().async {
            while true {
                do {
                    let response = try subscribeDispensesCall.receive()
                    
                    if case let result? = response {
                        print("Setting dispense = \(result.dispense)")
                        
                        DispatchQueue.main.async {
                            self.dispensing.onNext(result.dispense)
                            
                            print("Set to \(result.dispense)")
                        }
                    }
                } catch let error {
                    print("error: \(error)")
                    break
                }
            }
        }
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
    
    func showNoConnectionAlert() {
        var customSpec = errorSpec
        customSpec.durationType = .timed
        customSpec.timeToDismiss = 10.0
        
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tintColor = UIColor.white
        button.setTitle("Pair", for: .normal)
        button.addTarget(self, action: #selector(self.addDispenser), for: .touchUpInside)
        
        self.rControl.showMessage(
            withSpec: customSpec,
            atPosition: .navBarOverlay,
            title: "Candy dispenser unreachable",
            body: "Are you in the same network as your candy dispenser? Pair again if nothing else helps.",
            viewController: self.navigationController,
            rightView: button
        )
    }
    
    func toggleDispenseOnTouch(enable: Bool) {
        guard let client = self.client else {
            return
        }
        
        var req = Sweetrpc_SetDispenseOnTouchRequest()
        req.dispenseOnTouch = enable
        
        let res = try? client.setDispenseOnTouch(req)
        
        if res == nil {
            return
        }
        
        self.dispenseOnTouch.onNext(enable)
    }
    
    func toggleBuzzOnDispense(enable: Bool) {
        guard let client = self.client else {
            return
        }
        
        var req = Sweetrpc_SetBuzzOnDispenseRequest()
        req.buzzOnDispense = enable
        
        let res = try? client.setBuzzOnDispense(req)
        
        if res == nil {
            return
        }
        
        self.buzzOnDispense.onNext(enable)
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
        
        let disconnectAction = UIAlertAction(
            title: "Disconnect", style: .destructive, handler: { _ in
                guard let client = self.client else {
                    return
                }
                
                let req = Sweetrpc_DisconnectFromRemoteNodeRequest()
                
                let res = try? client.disconnectFromRemoteNode(req)
                
                if res == nil {
                    return
                }
                
                self.remoteNodeUrl.onNext(nil)
            }
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(disconnectAction)
        alert.addAction(cancelAction)
        
        self.navigationController.present(alert, animated: true, completion: nil)
    }
    
    func restart() {
        let alert = UIAlertController(
            title: "Restart",
            message: "You'll lose the connection to your dispenser for one or two minutes.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        let unpairAction = UIAlertAction(
            title: "Restart", style: .destructive, handler: { _ in
                guard let client = self.client else {
                    return
                }
                
                let req = Sweetrpc_RebootRequest()
                
                let res = try? client.reboot(req)
                
                if res == nil {
                    return
                }
            }
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(unpairAction)
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
    
    // exposed with @objc so method can be called from "no connection" alert
    @objc func addDispenser() {
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
            
            let action = UIAlertAction(title: dispenser.name, style: .default) { _ in
                self.coordinator.open(dispenser: dispenser)
            }
            
            optionMenu.addAction(action)
        }
        
        // Show option for pairing a new dispenser
        let addAction = UIAlertAction(title: "Add a candy dispenser...", style: .default) { _ in
            self.coordinator.pairNewDispenser()
        }
        
        // Color the option differently
        addAction.setValue(UIColor.darkText, forKey: "titleTextColor")
        
        optionMenu.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        self.navigationController.present(optionMenu, animated: true, completion: nil)
    }
    
    func showDetails() {
        let vc = DetailsViewController.instantiate(fromStoryboard: "Dispenser")
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func help() {
        self.coordinator.help()
    }
    
    func changeName(name: String) {
        guard let client = self.client else {
            return
        }
        
        var req = Sweetrpc_SetNameRequest()
        req.name = name
        
        let res = try? client.setName(req)
        
        if res == nil {
            return
        }
        
        self.name.onNext(name)
    }
    
    func completeRemoteNodeConnection(uri: String) {
        self.remoteNodeUrl.onNext(uri)
        
        self.remoteNodeCoordinator?.dismiss()
    }
    
    func toggleDispenser(on: Bool) {
        guard let client = self.client else {
            return
        }
        
        var req = Sweetrpc_ToggleDispenserRequest()
        req.dispense = on
        
        let res = try? client.toggleDispenser(req)
        
        if res == nil {
            return
        }
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
