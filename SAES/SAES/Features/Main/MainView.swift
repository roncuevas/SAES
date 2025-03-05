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
                    if newValue == false {
                        print("--- USER LOGGED OUT ---")
                        router.navigateBack(to: .login)
                    }
                }
                .onReceive(WebViewReceiver.shared.cookiesPublisher) { _ in
                    /* try? realm.write {
                        let userSession = realm.objects(UserSessionModel.self)
                        let userSessionFiltered = userSession.where {
                            $0.school == UserDefaults.schoolCode
                        }
                        guard let userSession = userSessionFiltered.first?.thaw() else { return }
                        realm.delete(userSession.cookies)
                        let object = newValue.toCookieModelList()
                        realm.add(object, update: .modified)
                        userSession.cookies = object
                    } */
                }
        } else {
            SetupView()
        }
    }
}
