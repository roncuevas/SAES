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
    }

    // MARK: - RemoteConfig Keys
    enum RemoteConfigKeys {
        static let requestReview = "saes_request_review"
        static let selectorsPersonalData = "selectors_personaldata_data"
    }

    // MARK: - Cookie Names
    enum CookieNames {
        static let aspxFormsAuth = ".ASPXFORMSAUTH"
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
        static let reviewRequestLoginCount: Int = 3
    }
}
