import Foundation

final class ConfigurationLoader: @unchecked Sendable {
    static let shared = ConfigurationLoader()
    private let lock = NSLock()
    private var cache: [String: Any] = [:]

    private init() {}

    func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        lock.lock()
        defer { lock.unlock() }

        if let cached = cache[filename] as? T {
            return cached
        }

        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw ConfigurationError.fileNotFound(filename)
        }

        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        cache[filename] = decoded
        return decoded
    }

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

    func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
    }
}

enum ConfigurationError: Error, Sendable {
    case fileNotFound(String)
}
