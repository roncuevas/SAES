import SwiftUI
import WebViewAMC

final class WebViewHandler: ObservableObject, WebViewMessageHandlerDelegate, WebViewCoordinatorDelegate {
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
    @Published var horarioSemanal = HorarioSemanal()
    @Published var grades: [GradeItem] = []
    @Published var gradesOrdered: [Grupo] = []
    @Published var kardex: (Bool, KardexModel?) = (false, nil)
    
    static var shared: WebViewHandler = WebViewHandler()
    
    private init() {}
    
    func messageReceiver(message: [String: Any]) {
        for (key, value) in message {
            processKeyValuePair(key: key, value: value)
        }
    }
    
    func cookiesReceiver(cookies: [HTTPCookie]) {
        var value = false
        if cookies.contains(where: {$0.name == ".ASPXFORMSAUTH" }) {
            value = true
        } else {
            value = false
        }
        guard isLogged != value else { return }
        isLogged = value
    }
    
    func didFailLoading(error: any Error) {
        Task {
            isErrorPage = true
            print(error)
            try await Task.sleep(nanoseconds: 2_000_000)
            isErrorPage = false
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
        case "grades":
            decodeAndAssignGrades(valueString: stringValue)
        case "kardex":
            setKardexInfo(valueString: stringValue)
        default:
            assignStringValue(forKey: key, valueString: stringValue)
        }
    }
    
    private func setKardexInfo(valueString: String) {
        guard let jsonData = valueString.data(using: .utf8) else { return }
        self.kardex.1 = try? JSONDecoder().decode(KardexModel.self, from: jsonData)
    }
    
    private func getAIResponse(from html: String, for type: String) {
        self.kardex.0 = true
        Task {
            let response: GPTResponseModel? = await NetworkManager.shared.sendRequest(url: NetworkManager.getURL(),
                                                                                      method: .post,
                                                                                      headers: NetworkManager.getKardexHeadersRequest(),
                                                                                      body: NetworkManager.getKardexBodyRequest(from: html),
                                                                                      type: GPTResponseModel.self)
            guard let data = response?.choices?.first?.message?.content?.data(using: .utf8) else { return }
            self.kardex.1 = try? JSONDecoder().decode(KardexModel.self, from: data)
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
            guard isLogged != value else { break }
            // self.isLogged = value
        case "isErrorPage":
            guard isErrorPage != value else { break }
            self.isErrorPage = value
        case "isErrorCaptcha":
            guard isErrorCaptcha != value else { break }
            self.isErrorCaptcha = value
        default:
            break
        }
    }

    private func decodeAndAssignSchedule(valueString: String) {
        guard let jsonData = valueString.data(using: .utf8),
              let schedule = try? JSONDecoder().decode([ScheduleItem].self, from: jsonData) else { return }
        guard self.schedule.count != schedule.count else { return }
        self.schedule = schedule
        for materia in schedule {
            let nombresDias = ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado"]
            for nombreDia in nombresDias {
                if let day = materia[dynamicMember: nombreDia], !day.isEmpty {
                    horarioSemanal.agregarMateria(dia: nombreDia.capitalized, materia: materia.materia, rangoHoras: day)
                }
            }
        }
    }

    private func decodeAndAssignGrades(valueString: String) {
        guard let jsonData = valueString.data(using: .utf8),
              let grades = try? JSONDecoder().decode([GradeItem].self, from: jsonData) else { return }
        self.grades = grades
        self.gradesOrdered = grades.transformToHierarchicalStructure()
        for grade in grades {
            print("Materia: \(grade.materia), Final: \(grade.final)")
        }
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
