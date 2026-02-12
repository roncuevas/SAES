import Foundation

struct SchoolData: Identifiable {
    var id: UUID = UUID()
    var name: String
    var longName: String
    var code: SchoolCodes
    var saes: String
    var order: Int = .zero
}
