import SwiftUI
import WebViewAMC

@MainActor
final class WebViewHandler: ObservableObject {
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Published var appError: SAESErrorType?
    @Published var isErrorCaptcha: Bool = false
    var isLoggingOut: Bool = false
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
        let manager = WebViewManager.shared
        manager.coordinator.setTimeout(AppConstants.Timing.webViewTimeout)

        // Typed message handlers
        manager.messageRouter.register(key: "imageData") { [weak self] message in
            self?.decodeAndAssignImageData(forKey: "imageData", dataString: message.rawValue)
        }
        manager.messageRouter.register(key: "profileImageData") { [weak self] message in
            self?.decodeAndAssignImageData(forKey: "profileImageData", dataString: message.rawValue)
        }
        manager.messageRouter.register(key: "isErrorPage") { [weak self] message in
            self?.assignBooleanValue(forKey: "isErrorPage", valueString: message.rawValue)
        }
        manager.messageRouter.register(key: "isErrorCaptcha") { [weak self] message in
            self?.assignBooleanValue(forKey: "isErrorCaptcha", valueString: message.rawValue)
        }
        manager.messageRouter.register(key: "schedule") { [weak self] message in
            self?.decodeAndAssignSchedule(valueString: message.rawValue)
        }
        manager.messageRouter.register(key: "grades") { [weak self] message in
            self?.decodeAndAssignGrades(valueString: message.rawValue)
        }
        manager.messageRouter.register(key: "kardex") { [weak self] message in
            self?.setKardexInfo(valueString: message.rawValue)
        }

        // Fallback for personal data (dynamic keys)
        manager.messageRouter.registerFallback { [weak self] message in
            self?.assignStringValue(forKey: message.key, valueString: message.rawValue)
        }

        // NavigationEvent stream for errors, timeout, and cookie updates
        Task { @MainActor [weak self] in
            for await event in manager.coordinator.events {
                switch event {
                case .failed(let error):
                    self?.handleLoadingError(error)
                case .timeout:
                    self?.appError = .serverError
                case .finished:
                    let cookies = await manager.cookieManager.getAllCookies()
                    self?.updateLoginState(from: cookies)
                case .started:
                    break
                }
            }
        }
    }

    private func handleLoadingError(_ error: Error) {
        if let urlError = error as? URLError,
           [.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed].contains(urlError.code) {
            appError = .noInternet
        } else {
            appError = .serverError
        }
        logger.log(level: .error, message: "\(error)", source: "WebViewHandler")
    }

    private func updateLoginState(from cookies: [HTTPCookie]) {
        Task {
            await UserSessionManager.shared.updateCookies(cookies.toLocalCookies)
        }
        let hasAuth = cookies.contains(where: { $0.name == AppConstants.CookieNames.aspxFormsAuth })
        guard isLogged != hasAuth else { return }
        if hasAuth {
            logger.log(level: .info, message: "isLogged cambió a true", source: "WebViewHandler")
            isLogged = true
        } else if isLoggingOut {
            isLoggingOut = false
            logger.log(level: .info, message: "isLogged cambió a false (logout)", source: "WebViewHandler")
            isLogged = false
        } else {
            logger.log(level: .info, message: "Sesión expirada detectada", source: "WebViewHandler")
            appError = .sessionExpired
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
            if value {
                guard appError == nil else { break }
                appError = .serverError
            }
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

    func dismissSessionExpired() {
        appError = nil
        isLogged = false
    }

    func retryError() {
        appError = nil
    }

    func clearData() {
        isLogged = false
        appError = nil
        isErrorCaptcha = false
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
