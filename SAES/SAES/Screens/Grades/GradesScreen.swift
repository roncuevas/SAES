import SwiftUI

struct GradesScreen {
    @EnvironmentObject var webViewMessageHandler: WebViewHandler
    @State var isRunningGrades: Bool = false
    @State var isLoadingScreen: Bool = false
    @State var isPresentingAlert: Bool = false
    @StateObject var viewModel: GradesViewModel = GradesViewModel()
}
