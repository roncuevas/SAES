import SwiftUI

struct ErrorStateView: View {
    let errorType: SAESErrorType
    let action: () -> Void
    var secondButtonTitle: String?
    var secondButtonIcon: String?
    var secondaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(iconColor)
            }
            .padding(.bottom, 8)

            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                Button(action: action) {
                    Label(buttonTitle, systemImage: buttonIcon)
                }
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
        .padding(40)
    }

    private var iconName: String {
        switch errorType {
        case .noInternet: return "wifi.slash"
        case .serverError: return "curlybraces"
        case .sessionExpired: return "timer"
        }
    }

    private var iconColor: Color {
        switch errorType {
        case .noInternet: return .red
        case .serverError: return .orange
        case .sessionExpired: return .yellow
        }
    }

    private var title: String {
        switch errorType {
        case .noInternet: return Localization.noInternetTitle
        case .serverError: return Localization.serverErrorTitle
        case .sessionExpired: return Localization.sessionExpiredTitle
        }
    }

    private var description: String {
        switch errorType {
        case .noInternet: return Localization.noInternetDescription
        case .serverError: return Localization.serverErrorDescription
        case .sessionExpired: return Localization.sessionExpiredDescription
        }
    }

    private var buttonTitle: String {
        switch errorType {
        case .noInternet, .serverError: return Localization.retry
        case .sessionExpired: return Localization.login
        }
    }

    private var buttonIcon: String {
        switch errorType {
        case .noInternet, .serverError: return "arrow.clockwise"
        case .sessionExpired: return "arrow.right.to.line"
        }
    }
}
