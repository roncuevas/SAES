import SwiftUI

struct SAESLoadingScreenModifier: ViewModifier {
    @Binding var isLoading: Bool

    func body(content: Content) -> some View {
        if isLoading {
            content
                .overlay {
                    ZStack {
                        Color.black.opacity(0.4)
                        VStack(spacing: 12) {
                            LottieLoadingView(size: 60)
                            Text(Localization.loading)
                                .font(.subheadline)
                                .foregroundStyle(.white)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                    .ignoresSafeArea()
                }
        } else {
            content
        }
    }
}

extension View {
    func saesLoadingScreen(isLoading: Binding<Bool>) -> some View {
        modifier(SAESLoadingScreenModifier(isLoading: isLoading))
    }
}
