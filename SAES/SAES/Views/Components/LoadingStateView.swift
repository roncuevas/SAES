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
        default:
            NoContentView(action: retryAction)
        }
    }
}
