import SwiftUI

extension ScholarshipsScreen: View {
    var body: some View {
        content
            .navigationTitle(Localization.becas)
            .searchable(
                text: $viewModel.searchText,
                prompt: Localization.searchScholarships
            )
            .task {
                await AnalyticsManager.shared.logScreen("scholarships")
                guard viewModel.scholarships.isEmpty else { return }
                await viewModel.getScholarships()
            }
            .refreshable {
                await viewModel.getScholarships()
            }
    }

    @ViewBuilder
    private var content: some View {
        LoadingStateView(
            loadingState: viewModel.loadingState,
            searchingTitle: Localization.searchingForScholarships,
            retryAction: { Task { await viewModel.getScholarships() } }
        ) {
            scholarshipsContent
        }
    }

    private var scholarshipsContent: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.filteredScholarships) { scholarship in
                    ScholarshipCardView(scholarship: scholarship)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}
