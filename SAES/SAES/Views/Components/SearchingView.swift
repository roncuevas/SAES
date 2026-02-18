import SwiftUI

struct SearchingView: View {
    var title: String = Localization.searching

    var body: some View {
        VStack(spacing: 12) {
            LottieLoadingView()
            Text(title)
                .foregroundStyle(.saes)
        }
    }
}
