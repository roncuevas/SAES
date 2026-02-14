import Foundation

struct Selector: Codable, Sendable {
    let id: String
    let selectors: [String]
}
