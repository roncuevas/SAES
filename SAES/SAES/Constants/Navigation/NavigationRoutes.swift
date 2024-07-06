import Foundation
import Routing
import SwiftUI

enum NavigationRoutes: Routable {
    case splashScreenView
    case mainView
    case setup
    case login
    case logged
    
    var body: some View {
        switch self {
        case .splashScreenView:
            SplashScreenView()
        case .mainView:
            MainView()
        case .setup:
            SetupView()
        case .login:
            LoginView()
        case .logged:
            LoggedView()
        }
    }
}
