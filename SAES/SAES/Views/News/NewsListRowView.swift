import SwiftUI
@preconcurrency import Kingfisher

struct NewsListRowView: View {
    @Environment(\.openURL) private var openURL
    let news: IPNStatementModelElement

    var body: some View {
        if let url = URL(string: "\(URLConstants.ipnBase)\(news.link)") {
            Button {
                openURL(url)
            } label: {
                rowContent
            }
            .buttonStyle(.plain)
        }
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            if let imageURL = URL(string: "\(URLConstants.ipnBase)\(news.imageURL)") {
                KFImage.url(imageURL)
                    .placeholder {
                        Color.gray.opacity(0.2)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipped()
                    .clipShape(.rect(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(news.title)
                    .font(.subheadline)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
                Text(news.date)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.saes)
            }

            Spacer(minLength: 0)
        }
    }
}
