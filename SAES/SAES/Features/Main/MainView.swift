import SwiftUI
import Routing
import RealmSwift

struct MainView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Environment(\.realm) private var realm
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var webViewCoordinator: WebViewCoordinator
    @ObservedResults(UserSessionModel.self) var userSession
    
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
        .onChange(of: webViewCoordinator.cookies) { newValue in
            try? realm.write {
                guard let userSession = userSession.thaw() else { return }
                guard let userSession = userSession.first else { return }
                realm.delete(userSession.cookies)
                userSession.cookies = newValue.toCookieModelList()
            }
        }
    }
}
