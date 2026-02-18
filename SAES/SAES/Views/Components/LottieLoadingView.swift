import Lottie
import SwiftUI

struct LottieLoadingView: View {
    @Environment(\.colorScheme) private var colorScheme

    var size: CGFloat = 80

    var body: some View {
        LottieView(animation: .named(colorScheme == .light ? "SAES" : "SAESblack"))
            .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
            .animationSpeed(EnvironmentConstants.animationSpeed)
            .configure { animationView in
                animationView.respectAnimationFrameRate = true
                animationView.shouldRasterizeWhenIdle = true
            }
            .frame(width: size, height: size)
    }
}
