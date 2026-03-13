import SwiftUI

struct MenuDebugButton: View {
    @Binding var isPresented: Bool

    var body: some View {
        #if DEBUG
            Button {
                isPresented.toggle()
            } label: {
                Label(Localization.debug, systemImage: "ladybug.fill")
            }
        #else
            EmptyView()
        #endif
    }
}
