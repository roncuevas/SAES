import Foundation

enum VersionComparer {
    /// Returns `true` when `current` is strictly older than `minimum`.
    /// Components are compared as major.minor.patch; missing parts default to 0.
    /// An empty `minimum` always returns `false` (no forced update).
    static func isOlderThan(current: String, minimum: String) -> Bool {
        guard !minimum.isEmpty else { return false }

        let currentParts = current.split(separator: ".").compactMap { Int($0) }
        let minimumParts = minimum.split(separator: ".").compactMap { Int($0) }

        let maxCount = max(currentParts.count, minimumParts.count)

        for i in 0..<maxCount {
            let cur = i < currentParts.count ? currentParts[i] : 0
            let min = i < minimumParts.count ? minimumParts[i] : 0

            if cur < min { return true }
            if cur > min { return false }
        }

        return false
    }
}
