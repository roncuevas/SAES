import Foundation

struct PersonalDataSelectorsModel: Codable {
    let version: String
    let selectors: [Selector]
}
