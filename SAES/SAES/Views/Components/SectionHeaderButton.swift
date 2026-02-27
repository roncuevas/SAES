import SwiftUI

struct SectionHeaderButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Label {
                    Text(text)
                        .font(.headline)
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: "link")
                        .font(.headline)
                        .foregroundStyle(.saes)
                        .clipShape(.circle)
                }
            }
            Spacer()
        }
    }
}
