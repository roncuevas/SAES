import SwiftUI

/// Call this with "@EnvironmentObject var navigationManager: NavigationManager" and then append the new view with "navigationManager.path.append(_the view_)"

struct NavigationManagerView<RootView: View>: View {
    
    @StateObject var webViewManager: WebViewManager = WebViewManager()
    @StateObject var navigationManager: NavigationManager = NavigationManager()
    private var rootView: RootView
    
    init(rootView: RootView) {
        self.rootView = rootView
    }
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            rootView
                .navigationDestination(for: NavigationRoute.self) { route in
                    route.associatedView()
                }
        }
        .environmentObject(navigationManager)
        .environmentObject(webViewManager)
    }
}

class NavigationManager: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    @Published var routesDebug: [NavigationRoute] = []
    
    func push(_ route: NavigationRoute) {
        path.append(route)
        routesDebug.append(route)
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func popToCount(numbers: Int) {
        path.removeLast(numbers)
    }
}
