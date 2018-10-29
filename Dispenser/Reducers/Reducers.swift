import Foundation
import ReSwift

func updateReducer(action: Action, state: UpdateState?) -> UpdateState {
    let state = state ?? UpdateState.none
    
    return state
}

func connectRemoteNodeReducer(action: Action, state: ConnectRemoteNodeState?) -> ConnectRemoteNodeState {
    let state = state ?? .none
    
    switch action {
    case let payload as DispenserActions.captureRemoteNodeConnection:
        return .captured(payload.remoteNodeConnection)
    case _ as DispenserActions.resetCapturedRemoteConnection:
        return .none
    case let payload as DispenserActions.setConnectingToRemoteNode:
        return .connecting(payload.remoteNodeConnection)
    case let payload as DispenserActions.setRemoteNodeConnectionFailed:
        return .failed(payload.remoteNodeConnection)
    case let payload as DispenserActions.setRemoteNodeConnectionSuccessful:
        return .connected(payload.remoteNodeConnection)
    default: break
    }
    
    return state
}

func appReducer(action: Action, state: AppState?) -> AppState {
    return AppState(
        pairing: nil,
        dispenser: nil,
        dispensers: [],
        connectRemoteNode: connectRemoteNodeReducer(action: action, state: state?.connectRemoteNode)
    )
}
