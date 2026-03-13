import SwiftUI

struct MenuContactEmailButton: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let iOSVersion = UIDevice.current.systemVersion
            let device = UIDevice.current.name
            let subject = Localization.contactEmailSubject
            let body = String(format: Localization.contactEmailBody, appVersion, iOSVersion, device)
            var components = URLComponents()
            components.scheme = "mailto"
            components.path = URLConstants.contactEmail
            components.queryItems = [
                URLQueryItem(name: "subject", value: subject),
                URLQueryItem(name: "body", value: body)
            ]
            guard let url = components.url else { return }
            openURL(url)
        } label: {
            Label(Localization.contactUs, systemImage: "envelope.fill")
                .tint(.saes)
        }
    }
}
