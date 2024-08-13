import SwiftUI
import Routing
import RealmSwift

struct MainView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Environment(\.realm) private var realm
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var webViewCoordinator: WebViewCoordinator
    @ObservedResults(UserSessionModel.self,
                     where: { $0.school == UserDefaults.schoolCode }) var userSession
    
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
                guard let userSession = userSession.first?.thaw() else { return }
                realm.delete(userSession.cookies)
                let object = newValue.toCookieModelList()
                realm.add(object, update: .modified)
                userSession.cookies = object
            }
        }
    }
}
