import SwiftUI
import WebKit
import WebViewAMC
@_exported import Inject

struct DebugToolbarModifier<ViewContent: View>: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @State var debug: Bool = false
    private var viewContent: ViewContent
    
    init(@ViewBuilder _ viewContent: () -> ViewContent) {
        self.viewContent = viewContent()
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        debug.toggle()
                    } label: {
                        Image(systemName: "ladybug.fill")
                            .tint(colorScheme == .dark ? .white : .black)
                    }
                    .sheet(isPresented: $debug) {
                        viewContent
                    }
                }
            }
        #if DEBUG
            .enableInjection()
        #endif
    }
}
