import Foundation
import SwiftUI
@preconcurrency import Kingfisher

struct NewsCardView: View {
    @Environment(\.openURL) private var openURL
    let new: IPNStatementModel.Element

    var body: some View {
        if let url = URL(string: "\(URLConstants.ipnBase)\(new.link)") {
            VStack(alignment: .leading, spacing: 8) {
                if let imageURL = URL(string: "\(URLConstants.ipnBase)\(new.imageURL)") {
                    KFImage.url(imageURL)
                        .placeholder {
                            Color.gray.opacity(0.2)
                                .frame(height: 80)
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12)) // <- esto limita el área de tap
                        .onTapGesture {
                            openURL(url)
                        }
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
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 1)
            )
        }
    }
}
