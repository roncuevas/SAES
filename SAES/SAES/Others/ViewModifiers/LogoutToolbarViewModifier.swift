import SwiftUI
import Routing

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
                        webViewManager.executeJS(.logout)
                        isLogged = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            router.navigateBack()
                        }
                    } label: {
                        Image(systemName: "door.right.hand.open")
                            .fontWeight(.bold)
                            .tint(.red)
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
