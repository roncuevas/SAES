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
    @Published var schedule: [ScheduleItem] = []
    
    static let shared: WebViewMessageHandler = WebViewMessageHandler()
    
    private init() {}
    
    func dictionaryReceiver(dictionary: [String: Any]) {
        for (key, value) in dictionary {
            processKeyValuePair(key: key, value: value)
        }
    }

    private func processKeyValuePair(key: String, value: Any) {
        guard let stringValue = value as? String else { return }

        switch key {
        case "imageData", "profileImageData":
            decodeAndAssignImageData(forKey: key, dataString: stringValue)
        case "isLogged", "isErrorPage", "isErrorCaptcha":
            assignBooleanValue(forKey: key, valueString: stringValue)
        case "schedule":
            decodeAndAssignSchedule(valueString: stringValue)
        default:
            assignStringValue(forKey: key, valueString: stringValue)
        }
    }

    private func decodeAndAssignImageData(forKey key: String, dataString: String) {
        guard let imageDecoded = dataString.convertDataURIToData() else { return }
        if key == "imageData" {
            self.imageData = imageDecoded
        } else {
            self.profileImageData = imageDecoded
        }
    }

    private func assignBooleanValue(forKey key: String, valueString: String) {
        let value = valueString.contains("1")
        switch key {
        case "isLogged":
            self.isLogged = value
        case "isErrorPage":
            self.isErrorPage = value
        case "isErrorCaptcha":
            self.isErrorCaptcha = value
        default:
            break
        }
    }

    private func decodeAndAssignSchedule(valueString: String) {
        guard let jsonData = valueString.data(using: .utf8),
              let schedule = try? JSONDecoder().decode([ScheduleItem].self, from: jsonData) else { return }
        self.schedule = schedule
    }

    private func assignStringValue(forKey key: String, valueString: String) {
        switch key {
        case "name": self.name = valueString
        case "curp": self.curp = valueString
        case "rfc": self.rfc = valueString
        case "birthday": self.birthday = valueString
        case "nationality": self.nationality = valueString
        case "birthLocation": self.birthLocation = valueString
        default: break
        }
    }
}
