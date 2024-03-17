import SwiftUI
import Routing

struct SchoolSelectorModifier: ViewModifier {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @EnvironmentObject private var router: Router<NavigationRoutes>
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSetted = false
                        router.navigateToRoot()
                    } label: {
                        Image(systemName: "graduationcap.fill")
                            .tint(.black)
                    }
                }
            }
    }
}

extension View {
    func schoolSelectorToolbar() -> some View {
        modifier(SchoolSelectorModifier())
    }
}
