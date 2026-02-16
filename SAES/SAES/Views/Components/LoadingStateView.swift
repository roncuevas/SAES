import SwiftUI

struct LoadingStateView<Content: View>: View {
    let loadingState: SAESLoadingState
    var searchingTitle: String = Localization.searching
    var retryAction: (() -> Void)?
    var secondButtonTitle: String?
    var secondButtonIcon: String?
    var secondaryAction: (() -> Void)?
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch loadingState {
        case .idle, .loading:
            SearchingView(title: searchingTitle)
        case .loaded:
            content()
        case .noNetwork:
            ErrorStateView(
                errorType: .noInternet,
                action: retryAction ?? {},
                secondButtonTitle: secondButtonTitle,
                secondButtonIcon: secondButtonIcon,
                secondaryAction: secondaryAction
            )
        default:
            NoContentView(
                secondButtonTitle: secondButtonTitle,
                secondButtonIcon: secondButtonIcon,
                action: retryAction,
                secondaryAction: secondaryAction
            )
        }
    }
}
