import CoreData
import RxSwift
import UIKit
import NMSSH
import BlueCapKit
import CoreBluetooth
import ObjectMapper

let candyServiceUUID = CBUUID(string: "ca000000-75dd-4a0e-b688-66b7df342cc6")
let networkAvailabilityStatusUUID = CBUUID(string: "ca000001-75dd-4a0e-b688-66b7df342cc6")
let ipAddressUUID = CBUUID(string: "ca000002-75dd-4a0e-b688-66b7df342cc6")
let wifiScanSignalUUID = CBUUID(string: "ca000003-75dd-4a0e-b688-66b7df342cc6")
let wifiScanListUUID = CBUUID(string: "ca000004-75dd-4a0e-b688-66b7df342cc6")
let wifiSsidStringUUID = CBUUID(string: "ca000005-75dd-4a0e-b688-66b7df342cc6")
let wifiPskStringUUID = CBUUID(string: "ca000006-75dd-4a0e-b688-66b7df342cc6")
let wifiConnectSignalUUID = CBUUID(string: "ca000007-75dd-4a0e-b688-66b7df342cc6")
let deviceNameUUID = CBUUID(string: "2A00")
let manufacturerNameUUID = CBUUID(string: "2A29")
let serialNumberUUID = CBUUID(string: "2A25")
let modelNumberUUID = CBUUID(string: "2A24")

public enum AppError : Error {
    case dataCharactertisticNotFound
    case enabledCharactertisticNotFound
    case updateCharactertisticNotFound
    case serviceNotFound
    case invalidState
    case resetting
    case poweredOff
    case unknown
    case unlikley
}

public enum GetStringValueError : Error {
    case failed
}

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
    var isConnectionInterrupted = false
    
    var fetchedSsid = BehaviorSubject<String>(value: "")
    var fetchedWifiNetworks = BehaviorSubject<[Wifi]>(value: [])
    var fetchedIpAddress = BehaviorSubject<String?>(value: "")
    var fetchedSerialNumber = BehaviorSubject<String?>(value: "")
    
    var selectedWifiNetwork: Network?
    var networks = BehaviorSubject<[Network]>(value: [])
    var disposeBag = DisposeBag()
    var centralManager: CentralManager!
    var centralState: ManagerState = .poweredOff
    var peripherial: Peripheral?
    var peripherialService: Service?
    var peripherialName = BehaviorSubject<String>(value: "")
    
    init(coordinator: AppCoordinator) {
        self.navigationController = PairingNavigationController.instantiate(fromStoryboard: "Pairing")
        self.coordinator = coordinator
        self.centralManager = CentralManager(options: [CBCentralManagerOptionRestoreIdentifierKey : "land.lightning.BLE" as NSString])
        
        Observable<[Network]>
            .combineLatest(self.fetchedWifiNetworks, self.fetchedSsid) { fetchedWifiNetworks, fetchedSsid in
                fetchedWifiNetworks.map {
                    return Network(ssid: $0.ssid!, connected: fetchedSsid == $0.ssid)
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
    
    func cleanup() {
        self.peripherial?.disconnect()
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

        let future = self.centralManager.whenStateChanges()
        .flatMap { state -> FutureStream<Peripheral> in
            switch state {
            case .poweredOn:
                return self.centralManager.startScanning(forServiceUUIDs: [candyServiceUUID], capacity: 10, timeout: 10.0)
            case .poweredOff:
                throw AppError.poweredOff
            case .unauthorized, .unsupported:
                throw AppError.invalidState
            case .resetting:
                throw AppError.resetting
            case .unknown:
                throw AppError.unknown
            }
        }.flatMap { peripheral -> FutureStream<Void> in
            self.centralManager.stopScanning()
            self.peripherial = peripheral
            self.peripherialName.onNext(self.peripherial!.name)
            return peripheral.connect(connectionTimeout: 10.0)
        }.flatMap { () -> Future<Void> in
            return self.peripherial!.discoverServices([candyServiceUUID])
        }.flatMap { () -> Future<Void> in
            guard let service = self.peripherial!.services(withUUID: candyServiceUUID)?.first else {
                throw AppError.serviceNotFound
            }
            self.peripherialService = service
            return service.discoverAllCharacteristics(timeout: 10.0)
        }
        
        future.onComplete {
            if $0.isSuccess() {
                DispatchQueue.main.async {
                    completionHandler?(.connected)
                }
            } else {
                switch $0.error! {
                case AppError.poweredOff:
                    DispatchQueue.main.async {
                        completionHandler?(.invalid)
                    }
                default:
                    DispatchQueue.main.async {
                        completionHandler?(.invalid)
                    }
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
        let vc = PairingWifiListViewController.instantiate(fromStoryboard: "Pairing")
        vc.coordinator = self
        
        self.getInfo()
        
        self.navigationController.pushViewController(vc, animated: true)
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
    
    func refreshWifiNetworks(completionHandler: (() -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let signalChar = self.peripherialService?.characteristics(withUUID: wifiScanSignalUUID)?.first else {
                return
            }
            
            guard let characteristic = self.peripherialService?.characteristics(withUUID: wifiScanListUUID)?.first else {
                return
            }
            
            var signal = UInt8(1)
            let signalData = Data(bytes: &signal, count: MemoryLayout.size(ofValue: signal))
            signalChar.write(data: signalData, timeout: 3.0)
                .flatMap { () -> Future<Void> in characteristic.read(timeout: 3.0) }
                .onComplete {
                    if $0.isFailure() {
                        return
                    }

                    guard let data = characteristic.dataValue else {
                        return
                    }
                    
                    guard let payload = String(data:data, encoding: .utf8) else {
                        return
                    }

                    let networks = payload.components(separatedBy: "\t").map { String.init($0) }.map { Wifi(ssid: $0) }
                    
                    self.fetchedWifiNetworks.onNext(networks)
                    
                    DispatchQueue.main.async {
                        completionHandler?()
                    }
                }
        }
    }
    
    func getStringValue(uuid: CBUUID, completionHandler: ((Try<String>) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let characteristic = self.peripherialService?.characteristics(withUUID: uuid)?.first else {
                return
            }
            
            let future = characteristic.read(timeout: 5.0)
            future.onComplete {
                if $0.isFailure() {
                    completionHandler?(Try<String>(GetStringValueError.failed))
                    return
                }
                
                guard let data = characteristic.dataValue else {
                    completionHandler?(Try<String>(GetStringValueError.failed))
                    return
                }
                
                guard let value = String(data:data, encoding: .utf8) else {
                    completionHandler?(Try<String>(GetStringValueError.failed))
                    return
                }
                
                completionHandler?(Try<String>(value))
            }
        }
    }
    
    func getInfo() {
        self.getStringValue(uuid: wifiSsidStringUUID) {
            guard let value = $0.value else { return }
            self.fetchedSsid.onNext(value)
        }
        
        self.getStringValue(uuid: ipAddressUUID) {
            guard let value = $0.value else { return }
            self.fetchedIpAddress.onNext(value)
        }
        
        self.getStringValue(uuid: serialNumberUUID) {
            guard let value = $0.value else { return }
            self.fetchedSerialNumber.onNext(value)
        }
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
        DispatchQueue.global(qos: .userInitiated).async {
            guard let ssidString = self.peripherialService?.characteristics(withUUID: wifiSsidStringUUID)?.first else {
                return
            }
            
            guard let pskString = self.peripherialService?.characteristics(withUUID: wifiPskStringUUID)?.first else {
                return
            }
            
            guard let connectSignal = self.peripherialService?.characteristics(withUUID: wifiConnectSignalUUID)?.first else {
                return
            }
            
            guard let ipAddress = self.peripherialService?.characteristics(withUUID: ipAddressUUID)?.first else {
                return
            }
            
            let ssidData = ssid.data(using: .utf8)!
            let pskData = password?.data(using: .utf8)
            
            var signal = UInt8(1)
            let signalData = Data(bytes: &signal, count: MemoryLayout.size(ofValue: signal))
            
            var first = true
            
            ssidString.write(data: ssidData, timeout: 3.0)
                .flatMap { () -> Future<Void> in
                    if let data = pskData {
                        return pskString.write(data: data, timeout: 3.0)
                    } else {
                        return Future<Void>()
                    }
                }
                .flatMap { () -> Future<Void> in
                    return connectSignal.write(data: signalData, timeout: 3.0)
                }
                .flatMap { () -> Future<Void> in
                    return ipAddress.startNotifying()
                }.flatMap { () -> FutureStream<Data?> in
                    return ipAddress .receiveNotificationUpdates(capacity: 2)
                }.onComplete {
                    // Ignore the immediate notification of the current IP
                    if (first) {
                        first = false
                        return
                    }
                    
                    if $0.isFailure() {
                        completionHandler?(.failed)
                    }
                    
                    guard let data = $0.value else {
                        completionHandler?(.failed)
                        return
                    }
                    
                    self.fetchedIpAddress.onNext(String(data: data!, encoding: .utf8))
                    
                    DispatchQueue.main.async {
                        completionHandler?(.connected)
                    }
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
        
        guard let ip = try? self.fetchedIpAddress.value() else {
            return
        }
        
        // Create gRPC service to internal address
        let address = String(format: "%@:%d", ip, 9000)
        let client = Sweetrpc_SweetServiceClient(address: address, secure: false)
        let req = Sweetrpc_GetInfoRequest()
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try _ = client.getInfo(req) { res, _ in
                    DispatchQueue.main.async {
                        guard let info = res else {
                            return
                        }
                    
                        // Do this to keep the client instance until the call is finished
                        // otherwise the call will finish with a nil response
                        _ = client
                        
                        let fetch: NSFetchRequest<Dispenser> = Dispenser.fetchRequest()
                        fetch.predicate = NSPredicate(format: "serial == %@", info.serial)
                        let dispensers = try? context.fetch(fetch) as [Dispenser]
                        
                        if let dispenser = dispensers?.first {
                            print("Dispenser already exists. Opening it...")
                            dispenserToOpen = dispenser
                            dispenserToOpen?.serial = info.serial
                            dispenserToOpen?.version = info.version
                            dispenserToOpen?.commit = info.commit
                            dispenserToOpen?.ip = ip
                            dispenserToOpen?.lastOpened = Date()
                        } else {
                            print("Dispenser is new. Creating and opening it...")
                            dispenserToOpen = Dispenser(context: context)
                            dispenserToOpen?.name = "Candy Dispenser"
                            dispenserToOpen?.serial = info.serial
                            dispenserToOpen?.version = info.version
                            dispenserToOpen?.commit = info.commit
                            dispenserToOpen?.ip = ip
                            dispenserToOpen?.lastOpened = Date()
                        }
                        
                        AppDelegate.shared.saveContext()
                        
                        // Disconnect from peripherial
                        self.peripherial?.disconnect()
                        
                        self.coordinator.open(dispenser: dispenserToOpen!)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                }
            }
        }
    }
}
