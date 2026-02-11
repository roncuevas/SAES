import SwiftUI
import Navigation
import WebViewAMC

struct SchoolSelectorModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: Router<NavigationRoutes>
    private let fetcher: WebViewDataFetcher
    
    init(fetcher: WebViewDataFetcher) {
        self.fetcher = fetcher
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaultsKeys.isSetted)
                        router.navigateToRoot()
                        fetcher.cancellAllTasks()
                    } label: {
                        Image(systemName: "graduationcap.fill")
                            .tint(colorScheme == .dark ? .white : .black)
                    }
                }
            }
    }
}
