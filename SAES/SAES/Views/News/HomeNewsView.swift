import Foundation
import SwiftUI
@preconcurrency import Kingfisher

struct HomeNewsView: View, NewsFetcher {
    @State private var news: IPNStatementModel = []
    let newsCount: Int
    let isGrid: Bool

    private var displayedNews: IPNStatementModel {
        Array(news.prefix(newsCount))
    }

    var body: some View {
        if isGrid {
            gridLayout
        } else {
            scrollLayout
        }
    }

    private var gridLayout: some View {
        LazyVGrid(columns: [.init(.flexible(), spacing: 12), .init(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(displayedNews) { new in
                homeNewsCard(new)
            }
        }
        .task { await loadNews() }
    }

    private var scrollLayout: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(displayedNews) { new in
                    homeNewsCard(new)
                        .frame(width: 180)
                }
            }
        }
        .task { await loadNews() }
    }

    @ViewBuilder
    private func homeNewsCard(_ new: IPNStatementModel.Element) -> some View {
        if let url = URL(string: "\(URLConstants.ipnBase)\(new.link)") {
            Button {
                openURL(url)
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    if let imageURL = URL(string: "\(URLConstants.ipnBase)\(new.imageURL)") {
                        KFImage.url(imageURL)
                            .placeholder {
                                Color(.imagePlaceholder)
                                    .frame(height: 100)
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipped()
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(new.date.uppercased())
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.saes)
                            .tracking(0.5)
                        Text(new.title)
                            .font(.caption.weight(.medium))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.primary)
                    }
                    .padding(10)
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .contentShape(.rect(cornerRadius: 14))
        }
    }

    @Environment(\.openURL) private var openURL

    private func loadNews() async {
        if news.isEmpty {
            news = await fetchNews()
        }
    }
}
