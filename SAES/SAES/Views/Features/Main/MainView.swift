import SwiftUI
import Routing

struct MainView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var webViewManager: WebViewManager
    @EnvironmentObject private var webViewMessageHandler: WebViewMessageHandler
    
    var body: some View {
        Group {
            if isSetted {
                LoginView()
            } else {
                SetupView()
            }
        }
        .onAppear {
            Task {
                await fetchLogged()
            }
            Task {
                await fetchErrorPage()
            }
        }
        .onChange(of: isLogged) { _ in
            if isLogged == false {
                router.navigateBack(to: .login)
            }
        }
    }
    
    private func fetchLogged() async {
        await WebViewFetcher.shared.fetchData(execute: .isLogged) {
            true
        }
    }
    
    private func fetchErrorPage() async {
        await WebViewFetcher.shared.fetchData(execute: .isErrorPage) {
            true
        }
    }
}
