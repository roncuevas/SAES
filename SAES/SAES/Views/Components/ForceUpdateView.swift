import SwiftUI

struct ForceUpdateView: View {
    let currentVersion: String
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
            .fill(.blue.opacity(0.15))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.blue)
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
        HStack(spacing: 16) {
            versionBadge(label: Localization.current, version: currentVersion, color: .red)

            Image(systemName: "arrow.right")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            versionBadge(label: Localization.forceUpdateNew, version: minimumVersion, color: .green)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func versionBadge(label: String, version: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(version)
                .font(.title3.bold())
                .foregroundStyle(color)
        }
        .frame(minWidth: 80)
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
