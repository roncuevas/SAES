import Foundation

final class ConfigurationLoader: @unchecked Sendable {
    static let shared = ConfigurationLoader()
    private let lock = NSLock()
    private var cache: [String: Any] = [:]

    private init() {}

    func loadJavaScript(from filename: String) -> String? {
        lock.lock()
        defer { lock.unlock() }

        if let cached = cache[filename] as? String {
            return cached
        }

        guard let url = Bundle.main.url(forResource: filename, withExtension: "js") else {
            return nil
        }

        guard let data = try? Data(contentsOf: url),
              let script = String(data: data, encoding: .utf8) else {
            return nil
        }

        cache[filename] = script
        return script
    }
}
