import Foundation
import ReSwift

typealias ActionCreator = (_ state: AppState, _ store: Store<AppState>) -> Action?

class DispenserActions {
    struct open: Action {
        let serial: String
        let version: String
        let commit: String
        let ip: String
    }
    
    struct captureRemoteNodeConnection: Action {
        let remoteNodeConnection: RemoteNodeConnection
    }
    
    struct resetCapturedRemoteConnection: Action {}
    
    struct setConnectingToRemoteNode: Action {
        let remoteNodeConnection: RemoteNodeConnection
    }
    
    struct setRemoteNodeConnectionFailed: Action {
        let remoteNodeConnection: RemoteNodeConnection
    }
    
    struct setRemoteNodeConnectionSuccessful: Action {
        let remoteNodeConnection: RemoteNodeConnection
    }
    
    struct setLatestRelease: Action {
        let oAuthUrl: URL?
    }
    
    static func connectToRemoteNode(nodeConnection: RemoteNodeConnection) -> ActionCreator {
        return { (state: AppState, store: Store<AppState>) -> Action? in
            store.dispatch(setConnectingToRemoteNode(remoteNodeConnection: nodeConnection))
            
            // TODO: Reuse service client connection
            let service = Sweetrpc_SweetServiceClient(address: "172.20.10.4:9000", secure: false)
            
            var req = Sweetrpc_ConnectToRemoteNodeRequest()
            req.uri = nodeConnection.uri
            req.cert = nodeConnection.cert.data(using: .utf8)!
            req.macaroon = Data(base64Encoded: nodeConnection.macaroon)!
            
            guard let res = try? service.connectToRemoteNode(req) else {
                return setRemoteNodeConnectionFailed(remoteNodeConnection: nodeConnection)
            }

            print(res)
            
            return setRemoteNodeConnectionSuccessful(remoteNodeConnection: nodeConnection)
        }
    }
    
    static func update(state: AppState, store: Store<AppState>) -> Action? {
        // TODO: Reuse service client connection
        _ = Sweetrpc_SweetServiceClient(address: "192.168.27.1:9000", secure: false)
        
        return nil
    }
    
    static func check(state: AppState, store: Store<AppState>) -> Action? {
        GetLatestRelease { release in
            DispatchQueue.main.async {
                store.dispatch(setLatestRelease(oAuthUrl: nil))
            }
        }
        
        return nil
    }
}
