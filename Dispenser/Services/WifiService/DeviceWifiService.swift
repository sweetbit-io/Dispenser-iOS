import NetworkExtension
import SystemConfiguration.CaptiveNetwork

class RealWifiService: WifiService {
    static let shared = RealWifiService()
    
    private init() {}
    
    func connect(ssid: String, password: String, completionHandler: ((WifiState) -> Void)? = nil) {
        let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        configuration.joinOnce = true
        
        NEHotspotConfigurationManager.shared.apply(configuration) { error in
            if error != nil {
                if error?.localizedDescription == "already associated." {
                    completionHandler?(.alreadyConnected)
                } else {
                    completionHandler?(.failed)
                }
            } else {
                if self.isConnectedToSsid(ssid: ssid) {
                    completionHandler?(.connected)
                } else {
                    completionHandler?(.failed)
                }
            }
        }
    }
    
    func disconnect(ssid: String) {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
    }
    
    func isConnectedToSsid(ssid: String) -> Bool {
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
