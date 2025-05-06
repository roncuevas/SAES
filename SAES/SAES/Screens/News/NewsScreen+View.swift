import SwiftUI

extension NewsScreen: View, NewsFetcher {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            NewsView(newsCount: 999, columnsCount: 2)
                .padding()
                .navigationTitle(Localization.news)
        }
        .task {
            AnalyticsManager.shared.logScreen("news")
            self.statements = await fetchNews()
        }
    }
}
