import NavigatorUI
import SwiftUI

enum AppDestination: NavigationDestination {
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

    var body: some View {
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
