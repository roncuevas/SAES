import SwiftUI
import Routing
import WebViewAMC

struct MainView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var webViewHandler: WebViewHandler
    let start = Date().addingTimeInterval(-30)
    let end = Date().addingTimeInterval(90)
    @State private var loadingText: String = "Loggeando"
    
    var body: some View {
        Group {
            if isSetted {
                LoginView()
                    .task {
                        WebViewManager.shared.fetcher.fetchInfinite(run: JScriptCode.isLogged.value,
                                                            description: "isLogged")
                        WebViewManager.shared.fetcher.fetchInfinite(run: JScriptCode.isErrorPage.value,
                                                            description: "isErrorPage")
                    }
                /*
                    .overlay(alignment: .center) {
                        ZStack {
                            Color.black.opacity(0.3)
                            ProgressView {
                                Text(loadingText)
                            }
                                .controlSize(.extraLarge)
                                .task {
                                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                                    loadingText = "Loading ..."
                                }
                        }
                        .ignoresSafeArea()
                    }
                 */
            } else {
                SetupView()
            }
        }
        .onChange(of: isLogged) {
            if isLogged == false {
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
    }
}
