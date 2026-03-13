import SwiftUI

struct MenuLinkButton: View {
    let title: String
    let icon: String
    let url: String
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            guard let url = URL(string: url) else { return }
            openURL(url)
        } label: {
            Label(title, systemImage: icon)
        }
    }
}
