import UIKit

// TODO: extract all pairing logic from vc's into this coordinator
class PairingCoordinator {
    var coordinator: AppCoordinator
    var navigationController: PairingNavigationController
    
    init(coordinator: AppCoordinator) {
        self.navigationController = PairingNavigationController.instantiate(fromStoryboard: "Pairing")
        self.coordinator = coordinator
    }
    
    func start() {
        let vc = StartSetupViewController.instantiate(fromStoryboard: "Pairing")
        vc.coordinator = self
        
        self.navigationController.setViewControllers([vc], animated: false)
    }
}
