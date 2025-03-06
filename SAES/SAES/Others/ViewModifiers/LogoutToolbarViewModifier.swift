import SwiftUI
import Routing
import WebViewAMC

struct LogoutToolbarViewModifier: ViewModifier {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @EnvironmentObject private var router: Router<NavigationRoutes>
    private let webViewManager: WebViewManager
    
    init(webViewManager: WebViewManager) {
        self.webViewManager = webViewManager
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            do {
                                WebViewActions.shared.cancelOtherFetchs()
                                webViewManager.webView.removeCookies([".ASPXFORMSAUTH"])
                                try await Task.sleep(nanoseconds: 500_000_000)
                                webViewManager.webView.loadURL(id: "logout", url: URLConstants.home.value)
                                // TODO: Clear cookies for that specific user
                            } catch {
                                Logger().error("\(error)")
                            }
                        }
                    } label: {
                        Image(systemName: "door.right.hand.open")
                            .fontWeight(.bold)
                            .tint(.saesColorRed)
                    }
                }
            }
    }
}

extension View {
    func logoutToolbar(webViewManager: WebViewManager) -> some View {
        modifier(LogoutToolbarViewModifier(webViewManager: webViewManager))
    }
}
