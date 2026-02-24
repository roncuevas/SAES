import SwiftUI
@preconcurrency import Kingfisher

struct NewsBannerView: View {
    @Environment(\.openURL) private var openURL
    let news: IPNStatementModelElement

    var body: some View {
        if let url = URL(string: "\(URLConstants.ipnBase)\(news.link)") {
            Button {
                openURL(url)
            } label: {
                bannerContent
            }
            .buttonStyle(.plain)
        }
    }

    private var bannerContent: some View {
        ZStack(alignment: .topLeading) {
            if let imageURL = URL(string: "\(URLConstants.ipnBase)\(news.imageURL)") {
                KFImage.url(imageURL)
                    .placeholder {
                        Color(.imagePlaceholder)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 0) {
                Text(Localization.featured)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.red, in: .capsule)

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text(news.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    Text(news.date)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(12)
        }
        .frame(height: 200)
        .clipShape(.rect(cornerRadius: 16))
        .contentShape(.rect(cornerRadius: 16))
    }
}
