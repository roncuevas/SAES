import SwiftUI

struct NoContentView: View {
    var title: String = Localization.noContentTitle
    var description: String = Localization.noContentDescription
    var buttonTitle: String = Localization.noContentRetry
    var icon: Image = Image(systemName: "exclamationmark.triangle.fill")
    var action: () -> Void
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

            HStack {
                Spacer()
                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
                Spacer()
                if secondaryAction != nil {
                    Button(buttonTitle, action: action)
                        .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
    }
}
