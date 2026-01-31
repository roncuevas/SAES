import SwiftUI

struct NoContentView: View {
    var title: String = Localization.noContentTitle
    var description: String = Localization.noContentDescription
    var firstButtonTitle: String = Localization.noContentRetry
    var secondButtonTitle: String?
    var icon: Image = Image(systemName: "exclamationmark.triangle.fill")
    var action: (() -> Void)?
    var secondaryAction: (() -> Void)?

    var body: some View {
        VStack {
            icon
                .foregroundStyle(.saes)
                .font(.system(size: 40))
                .padding(.bottom, 4)

            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 4)

            Text(description)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 4)

            if let action {
                HStack {
                    Spacer()
                    Button(firstButtonTitle, action: action)
                        .buttonStyle(.borderedProminent)
                    Spacer()
                    if let secondButtonTitle, let secondaryAction {
                        Button(secondButtonTitle, action: secondaryAction)
                            .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
    }
}
