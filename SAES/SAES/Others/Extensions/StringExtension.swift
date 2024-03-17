import Foundation

extension String {
    func convertDataURIToData() -> Data? {
        if let commaIndex = self.range(of: ",") {
            let base64String = self.suffix(from: commaIndex.upperBound)
            return Data(base64Encoded: String(base64String))
        }
        return nil
    }
}
