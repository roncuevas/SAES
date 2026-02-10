import Foundation

struct LocalUserModel: Codable, Equatable {
    let schoolCode: String
    let studentID: String
    let password: String
    let ivValue: String
    let cookie: [LocalCookieModel]
}
