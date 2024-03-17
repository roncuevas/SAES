import Foundation

extension Optional where Wrapped == Data {
    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
}
