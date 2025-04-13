import Foundation
import SwiftUI

struct NewsView: View, NewsFetcher {
    @State private var news: IPNStatementModel = []
    let newsCount: Int
    let columnsCount: Int
    private var gridItems: [GridItem] {
        Array(repeating: .init(.flexible(), spacing: 12), count: columnsCount)
    }

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 12) {
            ForEach(news.prefix(newsCount)) { new in
                NewsCardView(new: new)
            }
        }
        .task {
            news = await fetchNews()
        }
    }
}
