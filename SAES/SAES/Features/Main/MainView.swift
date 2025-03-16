import Routing
import SwiftUI
import WebViewAMC

struct MainView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var webViewHandler: WebViewHandler

    var body: some View {
        if isSetted {
            LoginView()
                .onChange(of: isLogged) { newValue in
                    if newValue, router.stack.last != .logged {
                        router.navigate(to: .logged)
                        do {
                            try AnalyticsManager.shared.sendData()
                        } catch {
                            print(error)
                        }
                    } else if newValue == false {
                        router.navigateBack()
                    }
                }
                .onChange(of: webViewHandler.personalData) { newValue in
                    guard let name = newValue["name"],
                          let email = newValue["email"]
                    else { return }
                    AnalyticsManager.shared.identify(name: name, email: email)
                }
        } else {
            SetupView()
        }
    }
}
