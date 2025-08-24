import SwiftUI

struct ScheduleAvailability: View {
    @StateObject private var viewModel = ScheduleAvailabilityViewModel()

    var body: some View {
        switch viewModel.loadingState {
        case .idle:
            Color.clear
                .task {
                    await viewModel.getData()
                }
        case .loading:
            SearchingView(title: Localization.searchingForPersonalData)
        case .loaded:
            loadedContent
        default:
            NoContentView {
                Task {
                    await viewModel.getData()
                }
            }
        }
    }

    private var loadedContent: some View {
        EmptyView()
    }
}
