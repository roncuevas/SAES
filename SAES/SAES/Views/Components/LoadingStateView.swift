import SwiftUI

struct LoadingStateView<Content: View>: View {
    let loadingState: SAESLoadingState
    var searchingTitle: String = Localization.searching
    var retryAction: (() -> Void)?
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch loadingState {
        case .idle, .loading:
            SearchingView(title: searchingTitle)
        case .loaded:
            content()
        case .noNetwork:
            ErrorStateView(errorType: .noInternet, action: retryAction ?? {})
        default:
            NoContentView(action: retryAction)
        }
    }
}
