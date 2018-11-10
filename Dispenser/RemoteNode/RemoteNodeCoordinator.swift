import UIKit

struct RemoteNodeConnection {
    var uri: String
    var cert: String
    var macaroon: String
}

class RemoteNodeCoordinator {
    var coordinator: DispenserCoordinator
    var navigationController: RemoteNodeNavigationController
    
    init(coordinator: DispenserCoordinator) {
        self.coordinator = coordinator
        self.navigationController = RemoteNodeNavigationController.instantiate(fromStoryboard: "RemoteNode")
    }
    
    func start() {
        let vc = RemoteNodeConnectViewController.instantiate(fromStoryboard: "RemoteNode")
        vc.coordinator = self
        
        self.navigationController.setViewControllers([vc], animated: false)
    }
    
    func captureRemoteNodeConnection(remoteNodeConnection: RemoteNodeConnection) {
        let vc = RemoteNodeConfirmViewController.instantiate(fromStoryboard: "RemoteNode")
        vc.coordinator = self
        vc.remoteNodeConnection = remoteNodeConnection
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func connectToRemoteNode(nodeConnection: RemoteNodeConnection) {
        var req = Sweetrpc_ConnectToRemoteNodeRequest()
        req.uri = nodeConnection.uri
        req.cert = nodeConnection.cert.data(using: .utf8)!
        req.macaroon = Data(base64Encoded: nodeConnection.macaroon)!
        
        guard let client = self.coordinator.client else {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let res = try? client.connectToRemoteNode(req)
            
            if res == nil {
                return
            }
         
            DispatchQueue.main.async {
                self.coordinator.completeRemoteNodeConnection(uri: nodeConnection.uri)
            }
        }
    }
    
    func dismiss() {
        self.navigationController.dismiss(animated: true)
    }
}
