import Foundation
import ObjectMapper

// TODO: Generalize remote connection for lnd, lightning-c, eclair

class RemoteNodeConnectionModel: Mappable {
    var uri: String?
    var cert: String?
    var macaroon: String?

    required init?(map: Map) {}

    func mapping(map: Map) {
        uri <- map["ip"]
        cert <- map["c"]
        macaroon <- map["m"]
    }
}
