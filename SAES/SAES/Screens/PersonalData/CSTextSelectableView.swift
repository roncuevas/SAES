import SwiftUI

struct CSTextSelectableView: View {
    let header: String
    var description: String?

    var body: some View {
        if let description, !description.replacingOccurrences(of: " ", with: "").isEmpty {
            HStack {
                Text(header)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(description)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.trailing)
                    .textSelection(.enabled)
            }
            .onTapGesture {
                UIPasteboard.general.string = description
            }
        }
    }
}
