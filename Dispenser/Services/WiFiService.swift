import NetworkExtension
import SystemConfiguration.CaptiveNetwork

enum WiFiState {
    case alreadyConnected
    case connected
    case failed
}

class WiFiService {
    static func connect(ssid: String, password: String, completionHandler: ((WiFiState) -> Void)? = nil) {
        let configuration = NEHotspotConfiguration(ssid: "candy", passphrase: "reckless", isWEP: false)
        configuration.joinOnce = true
        
        NEHotspotConfigurationManager.shared.apply(configuration) { error in
            if error != nil {
                if error?.localizedDescription == "already associated." {
                    completionHandler?(.alreadyConnected)
                } else {
                    completionHandler?(.failed)
                }
            } else {
                if WiFiService.isConnectedToSsid(ssid: "candy") {
                    completionHandler?(.connected)
                } else {
                    completionHandler?(.failed)
                }
            }
        }
    }
    
    static func disconnect(ssid: String) {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
    }
    
    static func isConnectedToSsid(ssid: String) -> Bool {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return false
        }
        
        for interfaceName in interfaceNames {
            guard let info = CNCopyCurrentNetworkInfo(interfaceName as CFString) as? [String: AnyObject] else {
                continue
            }
            
            guard let connectedSsid = info[kCNNetworkInfoKeySSID as String] as? String else {
                continue
            }
            
            return connectedSsid.compare(ssid) == .orderedSame
        }
        
        return false
    }
}
