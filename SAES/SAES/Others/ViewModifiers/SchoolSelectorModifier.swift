import SwiftUI

struct SchoolSelectorModifier: ViewModifier {
    @AppStorage("isSetted") private var isSetted: Bool = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSetted = false
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
