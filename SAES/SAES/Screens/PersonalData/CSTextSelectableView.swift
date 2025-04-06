import SwiftUI

struct CSTextSelectableView: View {
    let header: String
    var description: String?
    var image: UIImage?
    let pasteboard = UIPasteboard.general

    var body: some View {
        if let description, !description.replacingOccurrences(of: " ", with: "").isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(header)
                    .fontWeight(.bold)
                Text(description)
                    .textSelection(.enabled)
                if let image = image {
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: 100)
                        Spacer()
                    }
                }
            }
            .onTapGesture {
                pasteboard.string = description
            }
        }
    }
}
