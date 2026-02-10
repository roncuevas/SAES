import Foundation

struct WebViewBridgeConfiguration: Decodable {
    let messageKeys: [String]
    let taskIDs: [String]
    let dayNames: [String]
    let jsFunctions: [String: String]
}
