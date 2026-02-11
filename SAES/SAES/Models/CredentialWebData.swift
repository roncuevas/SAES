import Foundation

struct CredentialWebData: Codable, Equatable {
    let studentID: String
    let studentName: String
    let curp: String
    let career: String
    let school: String
    let cctCode: String
    let isEnrolled: Bool
    let statusText: String?
    let profilePictureBase64: String?
}
