import UIKit

class RemoteNodeConfirmViewController: UIViewController, Storyboarded {
    var coordinator: RemoteNodeCoordinator?
    @IBOutlet var connectButton: LoadingButton!
    var remoteNodeConnection: RemoteNodeConnection?
    
    @IBAction func dismiss(_ sender: Any) {
        self.coordinator?.dismiss()
    }
    
    @IBAction func connect(_ sender: LoadingButton) {
        guard let remoteNodeConnection = self.remoteNodeConnection else {
            return
        }
        
        self.coordinator?.connectToRemoteNode(nodeConnection: remoteNodeConnection)
    }
}
