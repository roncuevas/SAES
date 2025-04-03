import Foundation
import UIKit
import CryptoKit

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

    var sha256: Self {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02hhx", $0) }.joined()
    }

    func toJPEG(quality: CGFloat = 0.7) throws -> Data? {
        guard let imageData = Data(base64Encoded: self),
              let image = UIImage(data: imageData),
              let jpegData = image.jpegData(compressionQuality: quality) else {
            throw NSError(domain: "ConversionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert base64 to JPEG."])
        }
        return jpegData
    }
}
