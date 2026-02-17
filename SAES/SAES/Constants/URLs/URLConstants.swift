import Foundation

enum URLConstants {
    private static let externalURLs: ExternalURLsConfiguration = {
        // swiftlint:disable:next force_try
        try! ConfigurationLoader.shared.load(ExternalURLsConfiguration.self, from: "external_urls")
    }()

    // MARK: - Webcal
    static var webcalInPerson: String { externalURLs.webcal.inPerson }
    static var webcalRemote: String { externalURLs.webcal.remote }

    // MARK: - App
    static var feedbackForm: String { externalURLs.app.feedbackForm }
    static var testFlight: String { externalURLs.app.testFlight }
    static var appStoreReview: String { externalURLs.app.appStoreReview }
    static var privacyPolicy: String { externalURLs.app.privacyPolicy }

    // MARK: - API
    static var apiBase: String { externalURLs.api.base }
    static var scraperJS: String { externalURLs.api.base + externalURLs.api.scraperJS }
    static var ipnStatements: String { externalURLs.api.base + externalURLs.api.ipnStatements }
    static var ipnSchedule: String { externalURLs.api.base + externalURLs.api.ipnSchedule }

    // MARK: - IPN
    static var ipnBase: String { externalURLs.ipn.base }

    // MARK: - SAES Routes
    case base
    case standard
    case home
    case personalData
    case schedule
    case grades
    case kardex
    case personalPhoto
    case academic
    case evalTeachersBase
    case evalTeachers
    case schedulePDF
    case scheduleAvailability

    private static let routesConfig: SAESRoutesConfiguration = {
        // swiftlint:disable:next force_try
        try! ConfigurationLoader.shared.load(SAESRoutesConfiguration.self, from: "saes_routes")
    }()

    var baseURL: String {
        UserDefaults.standard.string(forKey: AppConstants.UserDefaultsKeys.saesURL) ?? ""
    }

    private var routeKey: String {
        switch self {
        case .base: "base"
        case .standard: "standard"
        case .home: "home"
        case .personalData: "personalData"
        case .schedule: "schedule"
        case .grades: "grades"
        case .kardex: "kardex"
        case .personalPhoto: "personalPhoto"
        case .academic: "academic"
        case .evalTeachersBase: "evalTeachersBase"
        case .evalTeachers: "evalTeachers"
        case .schedulePDF: "schedulePDF"
        case .scheduleAvailability: "scheduleAvailability"
        }
    }

    var value: String {
        let route = Self.routesConfig.routes[routeKey] ?? ""
        return baseURL + route
    }
}
