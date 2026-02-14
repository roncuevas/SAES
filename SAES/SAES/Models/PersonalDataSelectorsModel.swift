import Foundation

struct PersonalDataSelectorsModel: Codable, Sendable {
    let version: String
    let selectors: [Selector]
}
