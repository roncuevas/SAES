import Foundation

struct CredentialModel: Codable, Equatable {
    let qrData: String
    let scannedDate: Date
    let schoolCode: String
    var webData: CredentialWebData?
}
