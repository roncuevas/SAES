import Foundation

struct ServerStatus: Decodable, Sendable {
    let isOnline: Bool
    let schoolCode: String
    let responseTimeMs: Int?
}
