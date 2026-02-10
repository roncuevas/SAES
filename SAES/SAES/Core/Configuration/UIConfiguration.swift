import Foundation

struct UIConfiguration: Decodable {
    let animationSpeed: Int
    let homeMaxEvents: Int
    let homeNewsCount: Int
    let homeNewsColumns: Int
    let reviewRequestLoginCount: Int
}
