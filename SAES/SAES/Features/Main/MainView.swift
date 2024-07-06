import SwiftUI
import Routing

struct MainView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @EnvironmentObject private var router: Router<NavigationRoutes>
    
    var body: some View {
        Group {
            if isSetted {
                LoginView()
            } else {
                SetupView()
            }
        }
        .onChange(of: isLogged) { _ in
            if isLogged == false {
                router.navigateBack(to: .login)
            }
        }
    }
}
