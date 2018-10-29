import UIKit
import ReSwift

class RemoteNodeConfirmViewController: UIViewController, StoreSubscriber {
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            AppDelegate.shared.store.dispatch(DispenserActions.resetCapturedRemoteConnection())
        })
    }
    
    @IBAction func connect(_ sender: LoadingButton) {
        sender.showLoading()
        
        AppDelegate.shared.store.dispatch(DispenserActions.connectRemoteNode(state: <#T##AppState#>, store: <#T##Store<AppState>#>)())
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
            print(remoteNodeConnection.uri)
        default:
            return
        }
    }
}
