import Foundation
import SwiftUI

struct NewsView: View, NewsFetcher {
    @State private var news: IPNStatementModel = []
    var externalNews: IPNStatementModel?
    let newsCount: Int
    let columnsCount: Int
    private var gridItems: [GridItem] {
        Array(repeating: .init(.flexible(), spacing: 12), count: columnsCount)
    }

    private var displayedNews: IPNStatementModel {
        externalNews ?? news
    }

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 12) {
            ForEach(displayedNews.prefix(newsCount)) { new in
                NewsCardView(new: new)
            }
        }
        .task {
            if externalNews == nil {
                news = await fetchNews()
            }
        }
    }
}
