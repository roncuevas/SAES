import Foundation

@MainActor
final class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()

    @Published var pendingURL: URL?

    private init() {}

    func enqueue(_ url: URL) {
        pendingURL = url
    }

    @discardableResult
    func consume() -> URL? {
        defer { pendingURL = nil }
        return pendingURL
    }
}
