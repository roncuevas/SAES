import Foundation
import UIKit

extension SchoolCodes {
    func getImageName() -> String {
        return UIImage(named: self.rawValue) != nil ? self.rawValue : "default"
    }
}
