@preconcurrency import FirebaseRemoteConfig
import SwiftUI

struct MaintenanceView: View {
    @EnvironmentObject private var router: AppRouter
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.ipnNewsScreen,
        fallback: false
    ) private var ipnNewsScreen
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.ipnScheduleScreen,
        fallback: false
    ) private var ipnScheduleScreen

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            icon

            titleSection

            navigationRows

            Spacer()

            statusPill

            footer
        }
        .padding(32)
    }

    // MARK: - Icon

    private var icon: some View {
        Circle()
            .fill(.orange.opacity(0.15))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.orange)
            )
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(Localization.maintenanceTitle)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(Localization.maintenanceMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Navigation Rows

    private var navigationRows: some View {
        VStack(spacing: 12) {
            navigationRow(
                icon: "person.text.rectangle",
                title: Localization.viewMyCredential,
                color: .blue
            ) {
                router.navigateTo(.credential)
            }

            if ipnNewsScreen {
                navigationRow(
                    icon: "newspaper",
                    title: Localization.ipnNews,
                    color: .purple
                ) {
                    router.navigateTo(.news)
                }
            }

            if ipnScheduleScreen {
                navigationRow(
                    icon: "calendar",
                    title: Localization.upcomingEvents,
                    color: .green
                ) {
                    router.navigateTo(.ipnSchedule)
                }
            }
        }
    }

    private func navigationRow(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Status Pill

    private var statusPill: some View {
        Text(Localization.loginUnderMaintenance)
            .font(.caption.weight(.medium))
            .foregroundStyle(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.orange.opacity(0.12), in: Capsule())
    }

    // MARK: - Footer

    private var footer: some View {
        Text("\(Localization.version) \(appVersion)")
            .font(.caption2)
            .foregroundStyle(.quaternary)
    }
}
