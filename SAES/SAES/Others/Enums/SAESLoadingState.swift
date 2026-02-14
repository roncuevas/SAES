import Foundation

enum SAESLoadingState: Sendable {
    case idle
    case loading
    case loaded
    case error
    case noNetwork
    case empty
}
