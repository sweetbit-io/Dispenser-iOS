import Foundation

protocol WifiService {
    func connect(ssid: String, password: String, completionHandler: ((WifiState) -> Void)?)
    func disconnect(ssid: String)
}

enum WifiState {
    case alreadyConnected
    case connected
    case failed
}
