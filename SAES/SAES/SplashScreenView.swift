import SwiftUI
import FirebaseRemoteConfig

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var animationFinished: Bool = false
    @State var isPresenting: Bool = false
    
    var body: some View {
        if animationFinished {
            NavigationManagerView(rootView: MainView())
                .onAppear {
                    getRemoteConfig()
                }
        } else {
            LottieView(animationFinished: $animationFinished,
                       name: colorScheme == .light ? "SAES" : "SAESblack",
                       animationSpeed: EnvironmentConstants.animationSpeed)
                .frame(width: 220, height: 220)
        }
    }
    
    func getRemoteConfig() {
        typealias ConfigConstants = RemoteConfigConstants
        RemoteConfigManager.shared.setDefaultConfig(plist: ConfigConstants.plistFilename)
        RemoteConfigManager.shared.fetchConfig()
        let remoteAppVersion = RemoteConfigManager.shared.getValue(for: ConfigConstants.appVersion).stringValue ?? ""
        print("Version actual: \(remoteAppVersion)")
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
