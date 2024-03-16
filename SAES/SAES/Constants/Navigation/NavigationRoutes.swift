import Foundation
import Routing
import SwiftUI

enum NavigationRoute: Routable {
    case splashScreenView
    case mainView
    case login
    case personalData
    
    var body: some View {
        switch self {
        case .splashScreenView:
            SplashScreenView()
        case .mainView:
            MainView()
        case .login:
            LoginView()
        case .personalData:
            PersonalDataView()
        }
    }
}
