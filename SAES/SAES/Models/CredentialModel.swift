import Foundation

struct CredentialModel: Codable, Equatable, Sendable {
    let qrData: String
    let scannedDate: Date
    let schoolCode: String
    var webData: CredentialWebData?
}
