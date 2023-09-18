import Foundation

struct SchoolData: Identifiable {
    var id: UUID = UUID()
    var name: String
    var code: String
    var imageURL: String?
    var saes: String
}
