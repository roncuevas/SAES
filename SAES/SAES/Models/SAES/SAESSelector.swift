import Foundation

struct SAESSelector: Hashable, Identifiable, Sendable {
    let id: UUID = UUID()
    let type: String
    let selector: String?
    var value: String?
    var text: String?
}
