import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 60))
                .foregroundStyle(.saes)

            Text(Localization.maintenanceTitle)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(Localization.maintenanceMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
