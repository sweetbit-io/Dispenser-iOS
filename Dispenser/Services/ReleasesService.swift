import Alamofire
import AlamofireObjectMapper
import Foundation
import ObjectMapper

class ReleaseResponse: Mappable {
    var name: String?
    var version: String?
    var publishedAt: Date?
    var body: String?
    var assets: [ReleaseAssetResponse]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["name"]
        publishedAt <- (map["published_at"], CustomDateFormatTransform(formatString: "yyy-MM-dd'T'HH:mm:ssZ"))
        body <- map["body"]
        assets <- map["assets"]
        
        if let version = map["tag_name"].currentValue as? String {
            self.version = String(version.dropFirst())
        }
    }
}

class ReleaseAssetResponse: Mappable {
    var browserDownloadUrl: String?
    var name: String?
    var size: Int?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        browserDownloadUrl <- map["browser_download_url"]
        name <- map["name"]
        size <- map["size"]
    }
}

struct Release {
    var name: String
    var version: String
    var publishedAt: Date
    var notes: String
    var packages: [Package]
}

extension Release: Equatable {
    static func == (lhs: Release, rhs: Release) -> Bool {
        return lhs.version == rhs.version
    }
}

struct Package {
    var os: String
    var arch: String
    var size: Int
    var url: String
}

let assetNameEnding = ".tar.gz"

func GetLatestRelease(completionHandler: @escaping (Release?) -> Void) {
    // Draft and prereleases are not returned by this endpoint
    Alamofire.request("https://api.github.com/repos/the-lightning-land/sweetd/releases/latest")
        .responseObject(queue: DispatchQueue.global(qos: .background)) { (response: DataResponse<ReleaseResponse>) in
            guard let releaseResponse = response.result.value else {
                // throw an error?
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            
            let release = Release(
                name: releaseResponse.name!,
                version: releaseResponse.version!,
                publishedAt: releaseResponse.publishedAt!,
                notes: releaseResponse.body!,
                packages: releaseResponse.assets!.map { (asset: ReleaseAssetResponse) -> Package? in
                    // Only select release assets
                    guard asset.name!.hasSuffix(assetNameEnding) else {
                        return nil
                    }
                    
                    // Strip the file ending
                    let name = String(asset.name!.dropLast(assetNameEnding.count))
                    
                    // Parse file name in order to find out operating system and architecture
                    // ex. ["sweetd", "0.1.0", "linux", "armv6"]
                    let nameComponents = name.components(separatedBy: "_")
                    
                    return Package(
                        os: nameComponents[2], // ex. "linux"
                        arch: nameComponents[3], // ex. "armv6"
                        size: asset.size!,
                        url: asset.browserDownloadUrl!
                    )
                }.filter { $0 != nil }.map { $0! }
            )
            
            print("Got release \(release.name)")
            
            DispatchQueue.main.async {
                completionHandler(release)
            }
        }
}
