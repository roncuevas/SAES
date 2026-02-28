import Foundation
import SwiftUI
@preconcurrency import Kingfisher

struct NewsCardView: View {
    @Environment(\.openURL) private var openURL
    let new: IPNStatementModel.Element

    var body: some View {
        if let url = URL(string: "\(URLConstants.ipnBase)\(new.link)") {
            Button {
                openURL(url)
            } label: {
                cardContent
            }
            .buttonStyle(.plain)
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURL = URL(string: "\(URLConstants.ipnBase)\(new.imageURL)") {
                KFImage.url(imageURL)
                    .placeholder {
                        Color(.imagePlaceholder)
                            .frame(height: 80)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
            }
            Group {
                Text(new.title)
                    .font(.subheadline)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
                Text(new.date)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.saes)
            }
            .padding([.horizontal, .bottom], 8)
        }
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .shadow(radius: 1)
    }
}
