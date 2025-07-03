import SwiftUI
import WebKit
import Inject

struct PersonalDataScreen {
    @EnvironmentObject var webViewMessageHandler: WebViewHandler
    @State var isRunningPersonalData: Bool = false
    @ObserveInjection var forceRedraw
    @StateObject var viewModel: PersonalDataViewModel = PersonalDataViewModel()
}
