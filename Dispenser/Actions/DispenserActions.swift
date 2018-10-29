import Foundation
import ReSwift

typealias ActionCreator = (_ state: AppState, _ store: Store<AppState>) -> Action?

class DispenserActions {
    struct open: Action {
        let serial: String
        let version: String
        let commit: String
    }
    
    struct captureRemoteNodeConnection: Action {
        let remoteNodeConnection: RemoteNodeConnection
    }
    
    struct setLatestRelease: Action {
        let oAuthUrl: URL?
    }
    
    static func update(state: AppState, store: Store<AppState>) -> Action? {
        // TODO: Reuse service client connection
        let service = Sweetrpc_SweetServiceClient(address: "192.168.27.1:9000", secure: false)
        
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
    
//    static func captureRemoteNodeConnection(nodeConnection: RemoteNodeConnection) -> ActionCreator {
//        return { (state: AppState, store: Store<AppState>) in
//            return nil
//        }
//    }
    
//    static func captureRemoteNodeConnection(nodeConnection: RemoteNodeConnection) -> Action {
//        return
//    }
    
    static func connectRemoteNode(state: AppState, store: Store<AppState>) -> Action? {
        // TODO: Reuse service client connection
        let service = Sweetrpc_SweetServiceClient(address: "192.168.27.1:9000", secure: false)

        var req = Sweetrpc_ConnectToRemoteNodeRequest()
        req.uri = "coincenter.lnd.lightning.land:10009"
        req.cert = Data(base64Encoded: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM5RENDQXB1Z0F3SUJBZ0lRVHd5Zm9YZnBqYkJuRXZBZDBja1I0ekFLQmdncWhrak9QUVFEQWpBeE1SOHcKSFFZRFZRUUtFeFpzYm1RZ1lYVjBiMmRsYm1WeVlYUmxaQ0JqWlhKME1RNHdEQVlEVlFRREV3VnZkSFJsY2pBZQpGdzB4T0RFd01Ea3lNVEE1TXpsYUZ3MHhPVEV5TURReU1UQTVNemxhTURFeEh6QWRCZ05WQkFvVEZteHVaQ0JoCmRYUnZaMlZ1WlhKaGRHVmtJR05sY25ReERqQU1CZ05WQkFNVEJXOTBkR1Z5TUZrd0V3WUhLb1pJemowQ0FRWUkKS29aSXpqMERBUWNEUWdBRUY1aFlKVHhyNVZVK2laTjRtTnBlVDQwWHFvbllENGx5ZWE3NWllKzlxY1l0QllIdgpvS05Lei9VZmRxSFdXek5DYUh5SnZyWjl6NjdweUxDUHVjR3JIS09DQVpNd2dnR1BNQTRHQTFVZER3RUIvd1FFCkF3SUNwREFQQmdOVkhSTUJBZjhFQlRBREFRSC9NSUlCYWdZRFZSMFJCSUlCWVRDQ0FWMkNCVzkwZEdWeWdnbHMKYjJOaGJHaHZjM1NDSFdOdmFXNWpaVzUwWlhJdWJHNWtMbXhwWjJoMGJtbHVaeTVzWVc1a2dnUjFibWw0Z2dwMQpibWw0Y0dGamEyVjBod1IvQUFBQmh4QUFBQUFBQUFBQUFBQUFBQUFBQUFBQmh3VEFxQUpsaHdTc0VRQUJod1NzCkVnQUJoeEFxQWdGb2ZqWXNPN1Q3OHVWd0tOYjZoeEFxQWdGb2ZqWXNPd0UzV0plRG5PQitoeEFxQWdGb2ZqWXMKT3kydlFIQnYrZnlpaHhBcUFnRm9mallzTzJYeEx2U3VIaHRyaHhBcUFnRm9mallzTzJucUU5Unh6UGNQaHhBcQpBZ0ZvZmpZc085VWErL051VXdZNGh4QXFBZ0ZvZmpZc08vRmVCQ1VtaEoyZmh4QXFBZ0ZvZmpZc08rQTM2OWZyCnI0S0poeEQrZ0FBQUFBQUFBSjFUcXQrekM2bGhoeEQrZ0FBQUFBQUFBQUJDTnYvK2FRaFBoeEQrZ0FBQUFBQUEKQUdoYjh2LytjYkQ5aHhEK2dBQUFBQUFBQUt5LzB2LytqWC9UaHhEK2dBQUFBQUFBQUNqWTlmLys3d2VPaHdSdAp5c0FMTUFvR0NDcUdTTTQ5QkFNQ0EwY0FNRVFDSUdFQUpTb0JmOFI0czFWRkpqNWxLOEhJWTJrL0Nwc3kyaVpvCk1CSytzMkF5QWlCTDljbTJOdmswSWRUcjZ3VysxM1laMTZuUktCbzZubFBiU1h2ejcvbUk3QT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")!
        req.macaroon = Data(base64Encoded: "AgEDbG5kArsBAwoQNLTf9mTC3chI53oKNtTbZxIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaFgoHbWVzc2FnZRIEcmVhZBIFd3JpdGUaFwoIb2ZmY2hhaW4SBHJlYWQSBXdyaXRlGhYKB29uY2hhaW4SBHJlYWQSBXdyaXRlGhQKBXBlZXJzEgRyZWFkEgV3cml0ZQAABiCWcke69HRv3Nfu2igj558bUpYzSFBigdnIUiqj1N74uA==")!
        
        try? service.connectToRemoteNode(req)
        
        return nil
    }
}
