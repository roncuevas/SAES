import SwiftUI

struct SearchingView: View {
    @State var title: String = "Buscando..."
    
    var body: some View {
        ProgressView(title)
            .controlSize(.large)
            .tint(.saes)
            .foregroundStyle(.saes)
    }
}
