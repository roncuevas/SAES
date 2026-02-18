import SwiftUI
@preconcurrency import Inject

@MainActor
struct CredentialScreen {
    @StateObject var viewModel = CredentialViewModel()
    @Environment(\.displayScale) var displayScale
    @ObserveInjection var forceRedraw
}
