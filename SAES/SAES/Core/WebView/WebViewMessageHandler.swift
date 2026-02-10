import SwiftUI
import WebViewAMC

final class WebViewHandler: ObservableObject, WebViewMessageHandlerDelegate, WebViewCoordinatorDelegate {
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Published var isErrorPage: Bool = false
    @Published var isErrorCaptcha: Bool = false
    @Published var isTimeout: Bool = false
    @Published var imageData: Data?
    @Published var profileImage: UIImage?
    @Published var schedule: [ScheduleItem] = []
    @Published var horarioSemanal = HorarioSemanal()
    @Published var grades: [GradeItem] = []
    @Published var gradesOrdered: [Grupo] = []
    @Published var kardex: (Bool, KardexModel?) = (false, nil)
    @Published var personalData = [String: String]()
    
    static var shared: WebViewHandler = WebViewHandler()
    private let logger = Logger(logLevel: .error)
    private static let bridgeConfig: WebViewBridgeConfiguration = {
        // swiftlint:disable:next force_try
        try! ConfigurationLoader.shared.load(WebViewBridgeConfiguration.self, from: "webview_bridge")
    }()
    
    private init() {
        WebViewManager.shared.coordinator.setTimeout(AppConstants.Timing.webViewTimeout)
        WebViewManager.shared.handler.delegate = self
        WebViewManager.shared.coordinator.delegate = self
    }
    
    func messageReceiver(message: [String: Any]) {
        for (key, value) in message {
            processKeyValuePair(key: key, value: value)
        }
    }
    
    func cookiesReceiver(cookies: [HTTPCookie]) {
        Task {
            await UserSessionManager.shared.updateCookies(cookies.toLocalCookies)
        }
        // isLogged
        let value = cookies.contains(where: { $0.name == AppConstants.CookieNames.aspxFormsAuth })
        guard isLogged != value else { return }
        isLogged = value
    }
    
    func didFailLoading(error: any Error) {
        Task {
            isErrorPage = true
            logger.log(level: .error, message: "\(error)", source: "WebViewHandler")
            try await Task.sleep(for: .seconds(AppConstants.Timing.minimalDelay))
            isErrorPage = false
        }
    }
    
    func didTimeout() {
        isTimeout = true
    }

    private func processKeyValuePair(key: String, value: Any) {
        guard let stringValue = value as? String else { return }

        switch key {
        case "imageData", "profileImageData":
            decodeAndAssignImageData(forKey: key, dataString: stringValue)
        case "isErrorPage", "isErrorCaptcha":
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

    private func decodeAndAssignImageData(forKey key: String, dataString: String) {
        guard let imageDecoded = dataString.convertDataURIToData() else { return }
        if key == "imageData" {
            self.imageData = imageDecoded
        }
    }

    private func assignBooleanValue(forKey key: String, valueString: String) {
        let value = valueString.contains("1")
        switch key {
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
            let nombresDias = Self.bridgeConfig.dayNames
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
            logger.log(level: .debug, message: "Materia: \(grade.materia), Final: \(grade.final)", source: "WebViewHandler")
        }
    }

    private func assignStringValue(forKey key: String, valueString: String) {
        guard personalData[key] != valueString else { return }
        personalData.updateValue(valueString, forKey: key)
    }
    
    func clearData() {
        isLogged = false
        isErrorPage = false
        isErrorCaptcha = false
        isTimeout = false
        imageData = nil
        profileImage = nil
        schedule = []
        horarioSemanal = HorarioSemanal()
        grades = []
        gradesOrdered = []
        kardex = (false, nil)
        personalData = [:]
    }
}
