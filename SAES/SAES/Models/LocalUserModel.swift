import Foundation

struct LocalUserModel: Codable {
    let schoolCode: String
    let studentID: String
    let password: String
    let ivValue: String
    let cookie: [LocalCookieModel]
}
