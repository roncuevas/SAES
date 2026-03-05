import SwiftUI

struct WidgetEmptyView: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WidgetLoginPrompt: View {
    let icon: String

    var body: some View {
        WidgetEmptyView(
            icon: icon,
            message: "Inicia sesion en SAES para ver tus datos"
        )
    }
}
