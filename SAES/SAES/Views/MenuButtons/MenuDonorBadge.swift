import SwiftUI

struct MenuDonorBadge: View {
    @ObservedObject private var donorManager = DonorManager.shared
    @AppStorage(AppConstants.UserDefaultsKeys.showDonorBadge) private var showBadge = true

    var body: some View {
        if donorManager.isDonor && showBadge {
            Label(donorManager.donorTier.label, systemImage: donorManager.donorTier.icon)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(badgeColor))
        }
    }

    private var badgeColor: Color {
        switch donorManager.donorTier {
        case .none: .clear
        case .supporter: .pink
        case .patron: .orange
        case .champion: .purple
        }
    }
}
