import SwiftUI

struct ForceUpdateView: View {
    let minimumVersion: String
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            icon

            titleSection

            versionComparison

            Spacer()

            updateButton

            Text(Localization.forceUpdateIncompatible)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(32)
    }

    private var icon: some View {
        Circle()
            .fill(.saes.opacity(0.15))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.saes)
            )
    }

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(Localization.forceUpdateTitle)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(Localization.forceUpdateMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var versionComparison: some View {
        VStack(spacing: 4) {
            Text(Localization.forceUpdateRequired)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("> \(minimumVersion)")
                .font(.title3.bold())
                .foregroundStyle(.saes)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var updateButton: some View {
        Button {
            guard let url = URL(string: URLConstants.appStoreLink) else { return }
            openURL(url)
        } label: {
            Text(Localization.forceUpdateButton)
        }
        .buttonStyle(.filledStyle)
    }
}
