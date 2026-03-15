import SwiftUI

struct MenuDonorBadge: View {
    @ObservedObject private var donorManager = DonorManager.shared
    @AppStorage(AppConstants.UserDefaultsKeys.showDonorBadge) private var showBadge = true

    var body: some View {
        if donorManager.isDonor && showBadge {
            HStack(spacing: 6) {
                Text(donorManager.donorTier.hearts)
                Text(Localization.donorThanks)
                    .font(.subheadline.weight(.semibold))
                Text(donorManager.donorTier.hearts)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [.saes, .saes.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}
