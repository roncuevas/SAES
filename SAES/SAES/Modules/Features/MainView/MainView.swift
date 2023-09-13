import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    @AppStorage("isLogged") private var isLogged: Bool = false
    
    var body: some View {
        Group {
            if isLogged {
                LoginView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
