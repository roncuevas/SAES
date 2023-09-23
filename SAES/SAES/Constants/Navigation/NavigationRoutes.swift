import Foundation
import SwiftUI

enum NavigationRoute: Hashable {
    case splashScreenView
    case mainView
    case login
    case personalData
    
    @ViewBuilder func associatedView() -> some View {
        Group {
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
}
