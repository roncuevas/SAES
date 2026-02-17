import SwiftUI

struct CSTextSelectableView: View {
    let header: String
    var description: String?
    let pasteboard = UIPasteboard.general

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
                pasteboard.string = description
            }
        }
    }
}
