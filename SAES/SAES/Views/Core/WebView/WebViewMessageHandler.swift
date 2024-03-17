import SwiftUI

class WebViewMessageHandler: ObservableObject, MessageHandlerDelegate {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Published var isErrorPage: Bool = false
    @Published var imageData: Data?
    @Published var name: String = ""
    @Published var curp: String = ""
    @Published var rfc: String = ""
    
    func dictionaryReceiver(dictionary: [String: Any]) {
        for (key, value) in dictionary {
            guard let value = value as? String else { continue }
            switch key {
            case "imageData":
                guard let imageDecoded = value.convertDataURIToData() else { continue }
                self.imageData = imageDecoded
            case "isLogged":
                self.isLogged = value.contains("1")
            case "name":
                self.name = value
            case "curp":
                self.curp = value
            case "rfc":
                self.rfc = value
            case "isErrorPage":
                self.isErrorPage = value.contains("1")
            default:
                break
            }
        }
    }
}
