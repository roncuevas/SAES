import SwiftUI

struct NoContentView: View {
    var title: String = Localization.noContentTitle
    var description: String = Localization.noContentDescription
    var firstButtonTitle: String = Localization.noContentRetry
    var secondButtonTitle: String?
    var secondButtonIcon: String?
    var icon: Image = Image(systemName: "exclamationmark.triangle.fill")
    var iconColor: Color = .saes
    var action: (() -> Void)?
    var secondaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 100, height: 100)

                icon
                    .foregroundStyle(iconColor)
                    .font(.system(size: 40))
            }
            .padding(.bottom, 8)

            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            if let action {
                VStack(spacing: 12) {
                    Button(firstButtonTitle, action: action)
                        .buttonStyle(.filledStyle)

                    if let secondButtonTitle, let secondaryAction {
                        Button(action: secondaryAction) {
                            if let secondButtonIcon {
                                Label(secondButtonTitle, systemImage: secondButtonIcon)
                            } else {
                                Text(secondButtonTitle)
                            }
                        }
                        .buttonStyle(.outlinedStyle)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(40)
    }
}
