import Foundation

struct ServerStatus: Decodable {
    let isOnline: Bool
    let schoolCode: String
    let responseTimeMs: Int
}
