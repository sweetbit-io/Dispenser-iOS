import UIKit
import ReSwift

class RemoteNodeConfirmViewController: UIViewController, StoreSubscriber {
    
    @IBOutlet weak var connectButton: LoadingButton!
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
        
        AppDelegate.shared.store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.shared.store.unsubscribe(self)
    }
    
    func newState(state: AppState) {
        switch (state.connectRemoteNode) {
        case let .captured(remoteNodeConnection):
            self.remoteNodeConnection = remoteNodeConnection
            self.connectButton.hideLoading()
        case .connecting(_):
            self.connectButton.showLoading()
        case .failed(_):
            self.connectButton.hideLoading()
        case .connected(_):
            self.connectButton.hideLoading()
            self.dismiss(self)
        default:
            return
        }
    }
}
