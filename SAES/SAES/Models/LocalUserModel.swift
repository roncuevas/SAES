import Foundation

struct LocalUserModel: Codable {
    let schoolCode: String
    let studentID: String
    let password: String
    let iv: String
    let cookie: [LocalCookieModel]
}
