import ReSwift
import UIKit

class RemoteNodeConfirmViewController: UIViewController, StoreSubscriber, Storyboarded {
    var coordinator: RemoteNodeCoordinator?
    @IBOutlet var connectButton: LoadingButton!
    var remoteNodeConnection: RemoteNodeConnection?
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            AppDelegate.shared.store.dispatch(DispenserActions.resetCapturedRemoteConnection())
        })
    }
    
    @IBAction func connect(_ sender: LoadingButton) {
        guard let remoteNodeConnection = self.remoteNodeConnection else {
            return
        }
        
        let action = DispenserActions.connectToRemoteNode(nodeConnection: remoteNodeConnection)
        
        AppDelegate.shared.store.dispatch(action)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.connectButton.hideLoading()
        
        AppDelegate.shared.store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.shared.store.unsubscribe(self)
    }
    
    func newState(state: AppState) {
        switch state.connectRemoteNode {
        case .connecting:
            self.connectButton.showLoading()
        case .failed:
            self.connectButton.hideLoading()
        case .connected:
            self.connectButton.hideLoading()
            self.dismiss(self)
        default:
            return
        }
    }
}
