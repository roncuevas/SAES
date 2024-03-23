import SwiftUI

class WebViewMessageHandler: ObservableObject, MessageHandlerDelegate {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Published var isErrorPage: Bool = false
    @Published var isErrorCaptcha: Bool = false
    @Published var imageData: Data?
    @Published var profileImageData: Data?
    @Published var name: String = ""
    @Published var curp: String = ""
    @Published var rfc: String = ""
    @Published var birthday: String = ""
    @Published var nationality: String = ""
    @Published var birthLocation: String = ""
    
    func dictionaryReceiver(dictionary: [String: Any]) {
        for (key, value) in dictionary {
            guard let value = value as? String else { continue }
            switch key {
            case "imageData":
                guard let imageDecoded = value.convertDataURIToData() else { continue }
                self.imageData = imageDecoded
            case "profileImageData":
                guard let imageDecoded = value.convertDataURIToData() else { continue }
                self.profileImageData = imageDecoded
            case "isLogged":
                guard isLogged != value.contains("1") else { continue }
                self.isLogged = value.contains("1")
            case "name":
                self.name = value
            case "curp":
                self.curp = value
            case "rfc":
                self.rfc = value
            case "birthday":
                self.birthday = value
            case "nationality":
                self.nationality = value
            case "birthLocation":
                self.birthLocation = value
            case "isErrorPage":
                self.isErrorPage = value.contains("1")
            case "isErrorCaptcha":
                self.isErrorCaptcha = value.contains("1")
            default:
                break
            }
        }
    }
}
