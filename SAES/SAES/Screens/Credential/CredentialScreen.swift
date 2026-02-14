import SwiftUI
@preconcurrency import Inject

@MainActor
struct CredentialScreen {
    @StateObject var viewModel = CredentialViewModel()
    @ObserveInjection var forceRedraw
}
