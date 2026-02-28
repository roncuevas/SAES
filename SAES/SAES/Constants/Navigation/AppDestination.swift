import AppRouter
import SwiftUI

enum AppDestination: DestinationType {
    case splashScreenView
    case mainView
    case setup
    case login
    case logged
    case news
    case ipnSchedule
    case scheduleAvailability
    case scholarships
    case credential
    case settings

    @MainActor @ViewBuilder
    var destinationView: some View {
        switch self {
        case .splashScreenView:
            SplashScreenView()
        case .mainView:
            MainView()
        case .setup:
            SchoolSelectionScreen()
        case .login:
            LoginView()
        case .logged:
            LoggedView()
        case .news:
            NewsScreen()
        case .ipnSchedule:
            IPNScheduleScreen()
        case .scheduleAvailability:
            ScheduleAvailability()
        case .scholarships:
            ScholarshipsScreen()
        case .credential:
            CredentialScreen()
        case .settings:
            SettingsScreen()
        }
    }

    static func from(path: String, fullPath: [String], parameters: [String: String]) -> Self? {
        switch path {
        case "splash": return .splashScreenView
        case "main": return .mainView
        case "setup": return .setup
        case "login": return .login
        case "logged": return .logged
        case "news": return .news
        case "ipnSchedule": return .ipnSchedule
        case "scheduleAvailability": return .scheduleAvailability
        case "scholarships": return .scholarships
        case "credential": return .credential
        case "settings": return .settings
        default: return nil
        }
    }
}
