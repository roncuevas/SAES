import Foundation

struct SAESSelector: Hashable, Identifiable {
    let id: UUID = UUID()
    let type: String
    let selector: String?
    var value: String?
    var text: String?
}
