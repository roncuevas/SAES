import SwiftUI
import WebViewAMC

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func appErrorOverlay(isDataLoaded: Bool = false) -> some View {
        modifier(AppErrorOverlayModifier(isDataLoaded: isDataLoaded))
    }

    func webViewToolbar() -> some View {
        modifier(DebugToolbarModifier {
            WebViewReader { proxy in
                WebView(proxy: proxy)
                    .frame(height: 500)
            }
        })
    }

    func logoutToolbar() -> some View {
        modifier(LogoutToolbarViewModifier())
    }

    func schoolSelectorToolbar() -> some View {
        modifier(SchoolSelectorModifier())
    }

    func menuToolbar(items: [MenuItem]) -> some View {
        modifier(MenuViewModifier(items: items))
    }

    func navigationBarTitle(title: String,
                            titleDisplayMode: NavigationBarItem.TitleDisplayMode = .automatic,
                            background: Visibility = .automatic,
                            backButtonHidden: Bool = true) -> some View {
        modifier(
            NavigationViewModifier(
                title: title,
                titleDisplayMode: titleDisplayMode,
                background: background,
                backButtonHidden: backButtonHidden
            )
        )
    }
}
