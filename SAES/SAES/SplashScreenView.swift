import SwiftUI

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var animationFinished: Bool = false
    @State var isPresenting: Bool = false
    
    var body: some View {
        if animationFinished {
            NavigationManagerView(rootView: MainView())
        } else {
            LottieView(animationFinished: $animationFinished,
                       name: colorScheme == .light ? "SAES" : "SAESblack",
                       animationSpeed: EnvironmentConstants.animationSpeed)
                .frame(width: 220, height: 220)
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
