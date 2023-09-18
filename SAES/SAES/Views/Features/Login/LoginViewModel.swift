import Foundation
import SwiftUI

class LoginViewModel: MessageHandlerDelegate, ObservableObject {
    
    @Published var imageData: Data?
    @Published var isLogged: Bool = false
    
    func dictionaryReceiver(dictionary: [String: Any]) {
        for (key, value) in dictionary {
            switch key {
            case "imageData":
                guard let imageEncoded = value as? String else { return }
                guard let imageDecoded = imageEncoded.convertDataURIToData() else { return }
                self.imageData = imageDecoded
            case "isLogged":
                guard let isLogged = value as? String else { return }
                self.isLogged = isLogged.contains("1")
            default:
                break
            }
        }
    }
}
