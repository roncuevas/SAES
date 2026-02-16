import SwiftUI

enum AppDestination: Hashable {
    case splashScreenView
    case mainView
    case setup
    case login
    case logged
    case news
    case ipnSchedule
    case scheduleAvailability
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
        case .credential:
            CredentialScreen()
        case .settings:
            SettingsScreen()
        }
    }
}
