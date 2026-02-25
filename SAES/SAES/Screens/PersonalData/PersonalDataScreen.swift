import SwiftUI
@preconcurrency import Inject

@MainActor
struct PersonalDataScreen {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var webViewMessageHandler: WebViewHandler
    @State var showProfilePicturePreview: Bool = false
    @ObserveInjection var forceRedraw
    @StateObject var viewModel: PersonalDataViewModel = PersonalDataViewModel()
}
