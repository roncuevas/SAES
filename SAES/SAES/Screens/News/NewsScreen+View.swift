import SwiftUI

extension NewsScreen: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(statements ?? []) { statement in
                    if let url = URL(string: "https://www.ipn.mx\(statement.imageURL)") {
                        VStack(spacing: 8) {
                            Text(statement.title)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.saes)
                            Text(statement.date)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.saes)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 220)
                        .background {
                            ZStack {
                                AsyncImage(url: url) { image in
                                    image
                                        .image?
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 220)
                                        .clipped()
                                }
                                Color.white.opacity(0.9)
                                    .frame(height: 130)
                            }
                        }
                        .overlay {
                            Rectangle()
                                .stroke(.saes, lineWidth: 1)
                                .padding(.horizontal, -2)
                        }
                        .onTapGesture {
                            guard let url = URL(string: "https://www.ipn.mx\(statement.link)") else { return }
                            openURL(url)
                        }
                    } else {
                        SearchingView(title: Localization.searchingForNews)
                    }
                }
            }
        }
        .task {
            do {
                self.statements = try await NetworkManager.shared.sendRequest(url: statementsURL,
                                                                              type: IPNStatementModel.self)
            } catch {
                print(error)
            }
        }
    }
}
