import Foundation
import SwiftSoup
import FirebaseRemoteConfig

struct PersonalDataParser: SAESParser {
    func parse(data: Data) throws -> [String: String] {
        let selectorsModel = try RemoteConfig
            .remoteConfig()
            .configValue(forKey: "selectors_personaldata_data")
            .decoded(asType: PersonalDataSelectorsModel.self)
        let html = try convert(data)
        guard let body = html.body()
        else { throw SAESParserError.nodeNotFound }
        let parsed = selectorsModel.selectors.reduce(into: [String: String]()) { dict, selector in
            do {
                let text = try body.select(selector.selectors).text()
                if !text.isEmpty {
                    dict[selector.id] = text
                }
            } catch {
                debugPrint("Node not found for id: \(selector.id)")
            }
        }
        guard !parsed.isEmpty
        else { throw SAESParserError.noDataFound }
        return parsed
    }
}
