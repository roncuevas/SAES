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
        static let appearanceMode = "appearanceMode"
        static let defaultTab = "defaultTab"
        static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
        static let scheduleCalendarId = "scheduleCalendarId"
        static let showUpcomingEvents = "showUpcomingEvents"
        static let showNews = "showNews"
        static let showTodaySchedule = "showTodaySchedule"
        static let showScholarships = "showScholarships"
        static let showAnnouncements = "showAnnouncements"
        static let debugSettingsEnabled = "debugSettingsEnabled"
        static let screenshotMode = "screenshotMode"
        static let apiBaseURLOverride = "apiBaseURLOverride"
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
        static let minimumVersion = "saes_minimum_version"
        static let debugxScrapping = "ipn_debugx_scrapping"
        static let debugxLimit = "ipn_debugx_limit"
        static let contactEmail = "saes_contact_email"
        static let supportURL = "saes_support_url"
        static let feedbackFormURL = "saes_feedback_form_url"
        static let testFlightURL = "saes_testflight_url"
        static let privacyPolicyURL = "saes_privacy_policy_url"
        static let appStoreURL = "saes_app_store_url"
        static let apiBaseURL = "saes_api_base_url"
    }

    // MARK: - Cookie Names
    enum CookieNames {
        static var aspxFormsAuth: String { DetectionStringsConfiguration.shared.cookieName }
    }

    // MARK: - HTTP Headers
    enum HTTPHeaders {
        static let cookie = "Cookie"
    }

    // MARK: - Timeouts & Delays (in seconds)
    enum Timing {
        private static let config = TimingConfiguration.shared

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
        static var reviewRequestLoginCount: Int { UIConfiguration.shared.reviewRequestLoginCount }
    }
}
