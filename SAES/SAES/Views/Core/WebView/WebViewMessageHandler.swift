import SwiftUI

class WebViewMessageHandler: ObservableObject, MessageHandlerDelegate {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Published var imageData: Data?
    @Published var name: String = ""
    @Published var curp: String = ""
    
    func dictionaryReceiver(dictionary: [String: Any]) {
        for (key, value) in dictionary {
            print(dictionary)
            switch key {
            case "imageData":
                guard let imageEncoded = value as? String else { return }
                guard let imageDecoded = imageEncoded.convertDataURIToData() else { return }
                self.imageData = imageDecoded
            case "isLogged":
                guard let isLogged = value as? String else { return }
                self.isLogged = isLogged.contains("1")
            case "name":
                guard let name = value as? String else { return }
                self.name = name
            case "curp":
                guard let curp = value as? String else { return }
                self.curp = curp
            default:
                break
            }
        }
    }
}
