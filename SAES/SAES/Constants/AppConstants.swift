import Foundation

/// Centralized app constants for keys, identifiers, and configuration values
enum AppConstants {

    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let schoolCode = "schoolCode"
        static let saesURL = "saesURL"
        static let isLogged = "isLogged"
        static let isSetted = "isSetted"
        static let loggedCounter = "loggedCounter"
        static let credentialSchoolCode = "credentialSchoolCode"
    }

    // MARK: - RemoteConfig Keys
    enum RemoteConfigKeys {
        static let requestReview = "saes_request_review"
        static let selectorsPersonalData = "selectors_personaldata_data"
        static let ipnNewsScreen = "ipn_news_screen"
        static let ipnScheduleScreen = "ipn_schedule_screen"
        static let scheduleAvailabilityScreen = "saes_schedule_availability_screen"
        static let kardexScreen = "saes_kardex_screen"
        static let scheduleScreen = "saes_schedule_screen"
        static let teacherEvaluation = "saes_teacher_evaluation"
        static let maintenanceMode = "saes_maintenance_mode"
    }

    // MARK: - Cookie Names
    enum CookieNames {
        private static let detectionStrings: DetectionStringsConfiguration = {
            // swiftlint:disable:next force_try
            try! ConfigurationLoader.shared.load(DetectionStringsConfiguration.self, from: "detection_strings")
        }()

        static var aspxFormsAuth: String { detectionStrings.cookieName }
    }

    // MARK: - HTTP Headers
    enum HTTPHeaders {
        static let cookie = "Cookie"
    }

    // MARK: - Timeouts & Delays (in seconds)
    enum Timing {
        private static let config: TimingConfiguration = {
            // swiftlint:disable:next force_try
            try! ConfigurationLoader.shared.load(TimingConfiguration.self, from: "timing")
        }()

        static var webViewTimeout: TimeInterval { config.webViewTimeout }
        static var loginDelay: Double { config.loginDelay }
        static var logoutDelay: Double { config.logoutDelay }
        static var gradesRetryDelay: Double { config.gradesRetryDelay }
        static var gradesSecondRetryDelay: Double { config.gradesSecondRetryDelay }
        static var minimalDelay: Double { config.minimalDelay }
        static var reviewRequestDelay: Double { config.reviewRequestDelay }
    }

    // MARK: - Thresholds
    enum Thresholds {
        private static let uiConfig: UIConfiguration = {
            // swiftlint:disable:next force_try
            try! ConfigurationLoader.shared.load(UIConfiguration.self, from: "ui_config")
        }()

        static var reviewRequestLoginCount: Int { uiConfig.reviewRequestLoginCount }
    }
}
