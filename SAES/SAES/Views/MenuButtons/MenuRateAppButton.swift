import SwiftUI
import StoreKit

struct MenuRateAppButton: View {
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        Button {
            requestReview()
        } label: {
            Label(Localization.rateOurApp, systemImage: "star.circle.fill")
                .tint(.yellow)
        }
    }
}
