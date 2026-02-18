import SwiftUI

extension NewsScreen: View {
    var body: some View {
        content
            .navigationTitle(Localization.news)
            .searchable(
                text: $viewModel.searchText,
                prompt: Localization.searchNews
            )
            .task {
                await AnalyticsManager.shared.logScreen("news")
                guard viewModel.news.isEmpty else { return }
                await viewModel.getNews()
            }
            .refreshable {
                await viewModel.getNews()
            }
    }

    @ViewBuilder
    private var content: some View {
        LoadingStateView(
            loadingState: viewModel.loadingState,
            searchingTitle: Localization.searchingForNews,
            retryAction: { Task { await viewModel.getNews() } }
        ) {
            newsContent
        }
    }

    @ViewBuilder
    private var newsContent: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    if let featured = viewModel.featuredNews {
                        NewsBannerView(news: featured)
                    }

                    if !viewModel.remainingNews.isEmpty {
                        HStack {
                            Text(Localization.recent)
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }

                    switch viewModel.viewMode {
                    case .grid:
                        gridContent
                    case .list:
                        listContent
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)

            viewModeButton
                .padding(16)
                .padding(.bottom, 4)
        }
    }

    private var gridContent: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(viewModel.remainingNews) { news in
                NewsCardView(new: news)
            }
        }
    }

    private var listContent: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(viewModel.remainingNews.enumerated()), id: \.element.id) { index, news in
                if index > 0 {
                    Divider()
                }
                NewsListRowView(news: news)
                    .padding(.vertical, 8)
            }
        }
    }

    private var viewModeButton: some View {
        FloatingToggleButton(
            systemImage: viewModel.viewMode == .list ? "square.grid.2x2" : "list.bullet"
        ) {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.viewMode = viewModel.viewMode == .list ? .grid : .list
            }
        }
    }
}
