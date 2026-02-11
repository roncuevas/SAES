import SwiftUI
import Inject

struct CredentialScreen {
    @StateObject var viewModel = CredentialViewModel()
    @ObserveInjection var forceRedraw
}
