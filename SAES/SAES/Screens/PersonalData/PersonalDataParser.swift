import Foundation
import SwiftSoup
@preconcurrency import FirebaseRemoteConfig

struct PersonalDataParser: SAESParser {
    private let logger = Logger(logLevel: .error)
    func parse(data: Data) throws -> [String: String] {
        let selectorsModel = try RemoteConfig
            .remoteConfig()
            .configValue(forKey: AppConstants.RemoteConfigKeys.selectorsPersonalData)
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
                logger.log(level: .error, message: "Node not found for id: \(selector.id)", source: "PersonalDataParser")
            }
        }
        guard !parsed.isEmpty
        else { throw SAESParserError.noDataFound }
        return parsed
    }
}
