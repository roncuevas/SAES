import Foundation

struct SAESSelector: Hashable, Identifiable {
    let id: UUID = UUID()
    let type: String
    var idSelector: String?
    var name: String?
    var value: String?
    var text: String?
}
