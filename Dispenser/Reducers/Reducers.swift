import Foundation
import ReSwift

func updateReducer(action: Action, state: UpdateState?) -> UpdateState {
    let state = state ?? UpdateState.none
    
    return state
}

func appReducer(action: Action, state: AppState?) -> AppState {
    return AppState(
        pairing: nil,
        dispenser: nil,
        dispensers: [],
        connectRemoteNode: .none
    )
}
