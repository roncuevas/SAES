import SwiftUI
import Routing
import WebViewAMC

struct SchoolSelectorModifier: ViewModifier {
    @AppStorage("isSetted") private var isSetted: Bool = false
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
                        isSetted = false
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
