import Foundation

extension URL {
    var baseDomain: String? {
        guard let scheme = self.scheme, let host = self.host else { return nil }
        return "\(scheme)://\(host)"
    }
}
