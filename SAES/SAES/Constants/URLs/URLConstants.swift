import Foundation
@preconcurrency import FirebaseRemoteConfig

enum URLConstants {
    private static let externalURLs = ExternalURLsConfiguration.shared
    private static let remoteConfig = RemoteConfig.remoteConfig()

    private static func remoteString(forKey key: String, fallback: String) -> String {
        let value = remoteConfig.configValue(forKey: key).stringValue ?? ""
        return value.isEmpty ? fallback : value
    }

    // MARK: - Webcal
    static var webcalInPerson: String { externalURLs.webcal.inPerson }
    static var webcalRemote: String { externalURLs.webcal.remote }

    // MARK: - App
    static var contactEmail: String {
        remoteString(forKey: AppConstants.RemoteConfigKeys.contactEmail, fallback: "saes@roncuevas.com")
    }
    static var feedbackForm: String {
        remoteString(forKey: AppConstants.RemoteConfigKeys.feedbackFormURL, fallback: externalURLs.app.feedbackForm)
    }
    static var testFlight: String {
        remoteString(forKey: AppConstants.RemoteConfigKeys.testFlightURL, fallback: externalURLs.app.testFlight)
    }
    static var appStoreReview: String {
        remoteString(forKey: AppConstants.RemoteConfigKeys.appStoreURL, fallback: externalURLs.app.appStoreReview)
    }
    static var appStoreLink: String {
        appStoreReview.replacingOccurrences(of: "?action=write-review", with: "")
    }
    static var privacyPolicy: String {
        remoteString(forKey: AppConstants.RemoteConfigKeys.privacyPolicyURL, fallback: externalURLs.app.privacyPolicy)
    }
    static var support: String { externalURLs.app.support }
    static var termsAndConditions: String { externalURLs.app.termsAndConditions }

    // MARK: - API
    static var apiBaseURL: String {
        let override = UserDefaults.standard.string(forKey: AppConstants.UserDefaultsKeys.apiBaseURLOverride)
        if let override, !override.isEmpty {
            return override
        }
        return remoteString(forKey: AppConstants.RemoteConfigKeys.apiBaseURL, fallback: externalURLs.api.base)
    }
    static var scraperJS: String { apiBaseURL + externalURLs.api.scraperJS }
    static var ipnStatements: String { apiBaseURL + externalURLs.api.ipnStatements }
    static var ipnSchedule: String { apiBaseURL + externalURLs.api.ipnSchedule }
    static var ipnScholarships: String { apiBaseURL + externalURLs.api.ipnScholarships }
    static var ipnAnnouncements: String { apiBaseURL + externalURLs.api.ipnAnnouncements }
    static var ipnLimits: String { apiBaseURL + externalURLs.api.ipnLimits }
    static var saesSchoolsNS: String { apiBaseURL + externalURLs.api.saesSchoolsNS }
    static var saesSchoolsNMS: String { apiBaseURL + externalURLs.api.saesSchoolsNMS }
    static var saesStatusNS: String { apiBaseURL + externalURLs.api.saesStatusNS }
    static var saesStatusNMS: String { apiBaseURL + externalURLs.api.saesStatusNMS }
    static var scrapperDebug: String { apiBaseURL + "/ipn/v1/scrapper-debug" }

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

    private static let routesConfig = SAESRoutesConfiguration.shared

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
