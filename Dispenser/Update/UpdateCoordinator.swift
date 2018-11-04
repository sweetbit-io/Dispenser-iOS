import Drift
import NMSSH
import RxSwift
import UIKit

class UpdateCoordinator {
    var coordinator: DispenserCoordinator
    var navigationController: UpdateNavigationController
    var release: Release
    
    init(coordinator: DispenserCoordinator, release: Release) {
        self.coordinator = coordinator
        self.navigationController = UpdateNavigationController.instantiate(fromStoryboard: "Update")
        self.release = release
    }
    
    func start() {
        let vc = UpdateViewController.instantiate(fromStoryboard: "Update")
        vc.coordinator = self
        
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    func update(release: Release) {
        guard let url = release.packages.first?.url else {
            return
        }
        
        let vc = UpdatingViewController.instantiate(fromStoryboard: "Update")
        vc.coordinator = self
        
        self.navigationController.setViewControllers([vc], animated: true)
        
        DispatchQueue.global(qos: .background).async {
            var req = Sweetrpc_UpdateRequest()
            req.url = url
            
            _ = try? self.coordinator.client?.update(req)
            
            DispatchQueue.main.async {
                let vc = UpdateRestartNeededViewController.instantiate(fromStoryboard: "Update")
                vc.coordinator = self
                
                self.navigationController.setViewControllers([vc], animated: true)
            }
        }
    }
    
    func restart() {
        WiFiService.connect(ssid: "candy", password: "reckless") {
            switch $0 {
            case .alreadyConnected:
                fallthrough
            case .connected:
                let session = NMSSHSession(host: "192.168.27.1", andUsername: "pi")
                
                guard session.isConnected else {
                    let vc = UpdateRestartFailedViewController.instantiate(fromStoryboard: "Update")
                    vc.coordinator = self
                    self.navigationController.setViewControllers([vc], animated: true)
                    return
                }
                
                session.authenticate(byPassword: "raspberry")
                
                guard session.isAuthorized else {
                    let vc = UpdateRestartFailedViewController.instantiate(fromStoryboard: "Update")
                    vc.coordinator = self
                    self.navigationController.setViewControllers([vc], animated: true)
                    return
                }
                
                var error: NSError?
                
                session.channel.execute("sudo reboot", error: &error)
                
                if let actualError = error {
                    print("An Error Occurred: \(actualError)")
                }
                
                session.disconnect()
            default:
                let vc = UpdateConnectionFailedViewController.instantiate(fromStoryboard: "Update")
                vc.coordinator = self
                
                self.navigationController.setViewControllers([vc], animated: true)
            }
        }
    }
    
    func retryRestart() {
        let vc = UpdateRestartNeededViewController.instantiate(fromStoryboard: "Update")
        vc.coordinator = self
        
        self.navigationController.setViewControllers([vc], animated: true)
    }
    
    func cancel() {
        self.navigationController.dismiss(animated: true)
    }
    
    func help() {
        self.coordinator.help()
    }
}
