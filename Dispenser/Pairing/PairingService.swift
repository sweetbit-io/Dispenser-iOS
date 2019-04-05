import ObjectMapper

class Wifi: Mappable {
    var ssid: String?
    
    required init?(map: Map) {}
    
    init(ssid: String) {
        self.ssid = ssid
    }
    
    func mapping(map: Map) {
        ssid <- map["ssid"]
    }
}
