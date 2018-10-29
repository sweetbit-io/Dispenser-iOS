import Foundation
import ReSwift

enum UpdateState {
    case searching
    case none
    case updating(Release)
    case available(Release)
    // case networkError(Error) TODO: handle this globally
}

extension UpdateState: Equatable {
    static func ==(lhs: UpdateState, rhs: UpdateState) -> Bool {
        switch (lhs, rhs) {
        case (.searching, .searching):
            return true
        case (.none, .none):
            return true
        case (.updating, .updating):
            return true
        case let (.available(lhsRelease), .available(rhsRelease)):
            return lhsRelease == rhsRelease
        default:
            return false
        }
    }
}

struct DispenserState {
    var serial: String
    var name: String
    var update: UpdateState
}

struct PairingState {
}

struct RemoteNodeConnection {
    var uri: String
    var cert: String
    var macaroon: String
}

enum ConnectRemoteNodeState {
    case none
    case captured(RemoteNodeConnection)
    case connecting(RemoteNodeConnection)
    case connected(RemoteNodeConnection)
    case failed(RemoteNodeConnection)
}

struct AppState: StateType {
    var pairing: PairingState?
    var dispenser: DispenserState?
    var dispensers: [(name: String, serial: String)]
    var connectRemoteNode: ConnectRemoteNodeState
}
