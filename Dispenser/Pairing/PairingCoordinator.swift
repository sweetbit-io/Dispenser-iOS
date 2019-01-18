import CoreData
import RxSwift
import UIKit
import NMSSH

let internalGrpcAddress = "192.168.27.1:9000"

struct Network {
    // name of the WiFi
    var ssid: String
    // is dispenser already connected to that WiFi?
    var connected: Bool
}

extension Network: Hashable {
    static func == (lhs: Network, rhs: Network) -> Bool {
        return lhs.ssid == rhs.ssid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.ssid)
    }
}

enum ConnectionStatus {
    // successfully connected to WiFi and retrieved information
    case connected
    // connected to WiFi but unable to retrieve information
    case invalid
    // failed WiFi connection
    case unreachable
}

enum WifiStatus {
    // connected to WiFi
    case connected
    // failed connecting to WiFi
    case failed
}

enum UpdateStatus {
    // successfully updated
    case updated
    // could not connect
    case unreachable
    // could not authenticate
    case forbidden
    // checksums do not match
    case corrupted
    // failed
    case failed
}

enum RebootStatus {
    // successfully rebooted
    case rebooted
    // could not connect
    case unreachable
    // could not authenticate
    case forbidden
}

class PairingCoordinator {
    var coordinator: AppCoordinator
    var navigationController: PairingNavigationController
    var service: Sweetrpc_SweetServiceClient?
    var isConnectionInterrupted = false
    var fetchedInfo = BehaviorSubject<Sweetrpc_GetInfoResponse?>(value: nil)
    var fetchedWifiNetworks = BehaviorSubject<[Sweetrpc_WpaNetwork]>(value: [])
    var fetchedWifiInfo = BehaviorSubject<Sweetrpc_GetWpaConnectionInfoResponse?>(value: nil)
    var wifiService: WifiService
    var selectedWifiNetwork: Network?
    var networks = BehaviorSubject<[Network]>(value: [])
    var disposeBag = DisposeBag()
    
    init(coordinator: AppCoordinator) {
        self.navigationController = PairingNavigationController.instantiate(fromStoryboard: "Pairing")
        self.coordinator = coordinator
        
        #if targetEnvironment(simulator)
        // Use a mock wifi service here, so the app can be tested in simulator
        self.wifiService = SimulatedWifiService(viewController: self.navigationController)
        #else
        self.wifiService = RealWifiService.shared
        #endif
        
        Observable<[Network]>
            .combineLatest(self.fetchedWifiNetworks, self.fetchedWifiInfo) { fetchedWifiNetworks, fetchedWifiInfo in
                fetchedWifiNetworks.map {
                    return Network(ssid: $0.ssid, connected: fetchedWifiInfo?.ssid == $0.ssid)
                }.orderedSet
            }
            .bind(to: self.networks)
            .disposed(by: self.disposeBag)
    }
    
    func start() {
        let vc = PairingStartViewController.instantiate(fromStoryboard: "Pairing")
        vc.coordinator = self
        
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    func cancel() {
        guard let dispenserToOpen = self.coordinator.getLastOpenedDispenser() else {
            return
        }
        
        self.coordinator.open(dispenser: dispenserToOpen)
    }
    
    func help() {
        self.coordinator.help()
    }
    
    func startSetup() {
        let vc = PairingConnectViewController.instantiate(fromStoryboard: "Pairing")
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func connect(completionHandler: ((ConnectionStatus) -> Void)?) {
        self.isConnectionInterrupted = false
        
        self.wifiService.connect(ssid: "candy", password: "reckless") { wifiState in
            switch wifiState {
            case .alreadyConnected:
                fallthrough
            case .connected:
                if self.isConnectionInterrupted {
                    return
                }
                
                #if targetEnvironment(simulator)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    var info = Sweetrpc_GetInfoResponse()
                    info.name = "Test"
                    info.serial = "007"
                    info.buzzOnDispense = false
                    info.dispenseOnTouch = true
                    info.commit = "deadbeef"
                    info.version = "0.3.0"
                    self.fetchedInfo.onNext(info)
                    
                    var wifiInfo = Sweetrpc_GetWpaConnectionInfoResponse()
                    wifiInfo.ip = "localhost"
                    wifiInfo.ssid = "Lappert"
                    self.fetchedWifiInfo.onNext(wifiInfo)
                    
                    completionHandler?(.connected)
                }
                return
                #endif
                
                DispatchQueue.global(qos: .userInitiated).async {
                    // Create gRPC service to internal address
                    self.service = Sweetrpc_SweetServiceClient(address: internalGrpcAddress, secure: false)
                
                    do {
                        let req = Sweetrpc_GetInfoRequest()
                        
                        _ = try self.service?.getInfo(req) { res, result in
                            if result.success && res != nil {
                                DispatchQueue.main.async {
                                    self.fetchedInfo.onNext(res)
                                }
                                
                                let wifiReq = Sweetrpc_GetWpaConnectionInfoRequest()
                                
                                do {
                                    _ = try self.service?.getWpaConnectionInfo(wifiReq) { res, result in
                                        if result.success && res != nil {
                                            DispatchQueue.main.async {
                                                self.fetchedWifiInfo.onNext(res)
                                                completionHandler?(.connected)
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                completionHandler?(.invalid)
                                            }
                                        }
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        completionHandler?(.invalid)
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completionHandler?(.invalid)
                                }
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completionHandler?(.invalid)
                        }
                    }
                }
            default:
                if self.isConnectionInterrupted {
                    return
                }
                
                DispatchQueue.main.async {
                    completionHandler?(.unreachable)
                }
            }
        }
    }
    
    func showConnectionSucceeded() {
        let vc = PairingSucceededViewController.instantiate(fromStoryboard: "Pairing")
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func configure() {
        guard let info = try? self.fetchedInfo.value() else {
            return
        }
        
        guard let version = info?.version else {
            return
        }

        if version < "0.4.4" {
            let vc = PairingUpdateAvailableViewController.instantiate(fromStoryboard: "Pairing")
            vc.coordinator = self
            
            self.navigationController.pushViewController(vc, animated: true)
            
            return
        }
        
        let vc = PairingWifiListViewController.instantiate(fromStoryboard: "Pairing")
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func updateFirmware(completionHandler: ((UpdateStatus) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            let session = NMSSHSession.connect(toHost: "192.168.27.1", withUsername: "pi")
            
            guard session.isConnected else {
                DispatchQueue.main.async {
                    completionHandler?(.unreachable)
                }
                return
            }
            
            session.authenticate(byPassword: "raspberry")
        
            guard session.isAuthorized else {
                DispatchQueue.main.async {
                    completionHandler?(.forbidden)
                }
                return
            }
            
            let archiveURL = Bundle.main.url(forResource: "sweetd_0.4.4_linux_armv6", withExtension: ".tar.gz")!
            let checksumsURL = Bundle.main.url(forResource: "sweetd_0.4.4_checksums", withExtension: ".txt")!
            let checksumsSignatureURL = Bundle.main.url(forResource: "sweetd_0.4.4_checksums", withExtension: ".txt.sig")!
            
            guard session.channel.uploadFile(archiveURL.path, to: "/home/pi/") else {
                DispatchQueue.main.async {
                    completionHandler?(.failed)
                }
                return
            }
            
            guard session.channel.uploadFile(checksumsURL.path, to: "/home/pi/") else {
                DispatchQueue.main.async {
                    completionHandler?(.failed)
                }
                return
            }
            
            guard session.channel.uploadFile(checksumsSignatureURL.path, to: "/home/pi/") else {
                DispatchQueue.main.async {
                    completionHandler?(.failed)
                }
                return
            }
            
            var err: NSError?
            var res: String
            
            res = session.channel.execute("shasum -a 256 -s --check sweetd_0.4.4_checksums.txt && echo OK", error: &err)
            
            guard res.contains("OK") else {
                DispatchQueue.main.async {
                    completionHandler?(.corrupted)
                }
                return
            }
            
            res = session.channel.execute("sudo tar xfz sweetd_0.4.4_linux_armv6.tar.gz --strip-components=1 -C /usr/local/bin/ && echo OK", error: &err)
            
            guard res.contains("OK") else {
                DispatchQueue.main.async {
                    completionHandler?(.failed)
                }
                return
            }
            
            res = session.channel.execute("sudo chown root:staff /usr/local/bin/sweetd && echo OK", error: &err)
            
            guard res.contains("OK") else {
                DispatchQueue.main.async {
                    completionHandler?(.failed)
                }
                return
            }

            session.disconnect()
            
            DispatchQueue.main.async {
                completionHandler?(.updated)
            }
        }
    }
    
    func reboot(completionHandler: ((RebootStatus) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            let session = NMSSHSession.connect(toHost: "192.168.27.1", withUsername: "pi")
            
            guard session.isConnected else {
                DispatchQueue.main.async {
                    completionHandler?(.unreachable)
                }
                return
            }
            
            session.authenticate(byPassword: "raspberry")
            
            guard session.isAuthorized else {
                DispatchQueue.main.async {
                    completionHandler?(.forbidden)
                }
                return
            }
            
            var err: NSError?
            var res: String
            
            res = session.channel.execute("sudo shutdown -r now", error: &err)
            
            session.disconnect()
            
            DispatchQueue.main.async {
                completionHandler?(.rebooted)
            }
        }
    }
    
    func showConnectionUnreachable() {
        let vc = PairingUnreachableViewController.instantiate(fromStoryboard: "Pairing")
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func showConnectionInvalid() {
        let vc = PairingInvalidViewController.instantiate(fromStoryboard: "Pairing")
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func interruptConnection() {
        self.isConnectionInterrupted = true
    }
    
    func retryConnection() {
        self.navigationController.popViewController(animated: true)
        
        // Fake a click on the connect button
        if let vc = self.navigationController.topViewController as? PairingConnectViewController {
            vc.connect()
        }
    }
    
    func doUpdate(completionHandler: (() -> Void)?) {
        self.updateFirmware() { status in
            completionHandler?()
            
            switch status {
            case .corrupted:
                fallthrough
            case .failed:
                fallthrough
            case .forbidden:
                fallthrough
            case .unreachable:
                let alertController = UIAlertController(title: "Update failed", message: "Updated failed: \(status)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { action in
                    self.configure()
                })
                
                self.navigationController.present(alertController, animated: true, completion: nil)
            case .updated:
                let vc = PairingUpdateSucceededViewController.instantiate(fromStoryboard: "Pairing")
                vc.coordinator = self
                
                self.navigationController.pushViewController(vc, animated: true)
            }
        }
    }
    
    func doReboot(completionHandler: (() -> Void)?) {
        self.reboot() { status in
            completionHandler?()
            
            switch status {
            case .forbidden:
                fallthrough
            case .unreachable:
                let alertController = UIAlertController(title: "Reboot failed", message: "Reboot failed: \(status)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default) { action in
                    self.configure()
                })
                
                self.navigationController.present(alertController, animated: true, completion: nil)
            case .rebooted:
                let vc = PairingUpdateReconnectViewController.instantiate(fromStoryboard: "Pairing")
                vc.coordinator = self
                
                self.navigationController.pushViewController(vc, animated: true)
            }
        }
    }
    
    func refreshWifiNetworks(completionHandler: (() -> Void)?) {
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.networks.onNext([
                Network(ssid: "One Green Family", connected: false),
                Network(ssid: "Zeko & Cody", connected: true),
                Network(ssid: "Lappert", connected: false),
            ])
            completionHandler?()
        }
        #else
        DispatchQueue.global(qos: .userInitiated).async {
            let req = Sweetrpc_GetWpaNetworksRequest()
            
            _ = try? self.service?.getWpaNetworks(req) { response, result in
                DispatchQueue.main.async {
                    if let res = response, result.success {
                        self.fetchedWifiNetworks.onNext(res.networks)
                    }
                    
                    completionHandler?()
                }
            }
        }
        #endif
    }
    
    func selectWifi(network: Network) {
        self.selectedWifiNetwork = network
        
        if !network.connected {
            let vc = PairingWifiAuthViewController.instantiate(fromStoryboard: "Pairing")
            vc.coordinator = self
            vc.ssid = network.ssid
            
            self.navigationController.pushViewController(vc, animated: true)
        } else {
            let vc = PairingFinishedViewController.instantiate(fromStoryboard: "Pairing")
            vc.coordinator = self
            
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func connectToWifi(ssid: String, password: String?, completionHandler: ((WifiStatus) -> Void)?) {
        var req = Sweetrpc_ConnectWpaNetworkRequest()
        req.ssid = ssid
        req.psk = password ?? ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                _ = try self.service?.connectWpaNetwork(req) { res, result in
                    if res?.status == .connected {
                        let wifiReq = Sweetrpc_GetWpaConnectionInfoRequest()
                        
                        do {
                            _ = try self.service?.getWpaConnectionInfo(wifiReq) { res, result in
                                if result.success && res != nil {
                                    self.fetchedWifiInfo.onNext(res)
                                    
                                    DispatchQueue.main.async {
                                        completionHandler?(.connected)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        completionHandler?(.failed)
                                    }
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completionHandler?(.failed)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            completionHandler?(.failed)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler?(.failed)
                }
                return
            }
        }
    }
    
    func showFinished() {
        let vc = PairingFinishedViewController.instantiate(fromStoryboard: "Pairing")
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func finishPairing() {
        var dispenserToOpen: Dispenser?
        
        let context = AppDelegate.shared.persistentContainer.viewContext
        
        guard let info = (try? self.fetchedInfo.value()) ?? nil else {
            return
        }
        
        guard let wifiInfo = (try? self.fetchedWifiInfo.value()) ?? nil else {
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
            dispenserToOpen?.ip = wifiInfo.ip
            dispenserToOpen?.lastOpened = Date()
        } else {
            print("Dispenser is new. Creating and opening it...")
            dispenserToOpen = Dispenser(context: context)
            dispenserToOpen?.name = "Candy Dispenser"
            dispenserToOpen?.serial = info.serial
            dispenserToOpen?.version = info.version
            dispenserToOpen?.commit = info.commit
            dispenserToOpen?.ip = wifiInfo.ip
            dispenserToOpen?.lastOpened = Date()
        }
        
        AppDelegate.shared.saveContext()
        
        self.coordinator.open(dispenser: dispenserToOpen!)
        
        self.wifiService.disconnect(ssid: "candy")
    }
}
