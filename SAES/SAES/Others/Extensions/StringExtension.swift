import Foundation

extension String {
    func convertDataURIToData() -> Data? {
        if let commaIndex = self.range(of: ",") {
            let base64String = self.suffix(from: commaIndex.upperBound)
            return Data(base64Encoded: String(base64String))
        }
        return nil
    }
    
    var colon: Self {
        return self.appending(":")
    }
    
    var space: Self {
        return self.appending(" ")
    }
    
    var localized: Self {
        return NSLocalizedString(self, comment: "")
    }
}
