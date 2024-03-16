import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    
    var body: some View {
        Group {
            if isSetted {
                LoginView()
            } else {
                SetupView()
            }
        }
    }
}
