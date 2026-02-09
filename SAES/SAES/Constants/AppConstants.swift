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
        static let webViewTimeout: TimeInterval = 10
        static let loginDelay: Double = 4.0
        static let logoutDelay: Double = 0.5
        static let gradesRetryDelay: Double = 2.0
        static let gradesSecondRetryDelay: Double = 1.0
        static let minimalDelay: Double = 0.005
        static let reviewRequestDelay: Double = 0.005
    }

    // MARK: - Thresholds
    enum Thresholds {
        static let reviewRequestLoginCount: Int = 3
    }
}
