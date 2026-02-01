import SwiftUI

struct SearchingView: View {
    var title: String = Localization.searching
    
    var body: some View {
        ProgressView(title)
            .controlSize(.large)
            .tint(.saes)
            .foregroundStyle(.saes)
    }
}
