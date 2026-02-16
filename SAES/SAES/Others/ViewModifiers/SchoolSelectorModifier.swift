import SwiftUI
import WebViewAMC

struct SchoolSelectorModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var proxy: WebViewProxy

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaultsKeys.isSetted)
                        router.popToRoot()
                        proxy.fetcher.cancelAllTasks()
                    } label: {
                        Image(systemName: "graduationcap.fill")
                            .tint(colorScheme == .dark ? .white : .black)
                    }
                }
            }
    }
}
