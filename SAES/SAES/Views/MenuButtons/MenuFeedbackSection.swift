import SwiftUI

struct MenuFeedbackSection: View {
    var body: some View {
        Menu {
            MenuContactEmailButton()
            MenuLinkButton(
                title: Localization.sendFeedback,
                icon: "bubble.and.pencil.rtl",
                url: URLConstants.feedbackForm
            )
            .tint(.saes)
            MenuLinkButton(
                title: Localization.joinBeta,
                icon: "testtube.2",
                url: URLConstants.testFlight
            )
            .tint(.blue)
            MenuLinkButton(
                title: Localization.writeAReview,
                icon: "star.bubble.fill",
                url: URLConstants.appStoreReview
            )
            .tint(.yellow)
        } label: {
            Label(Localization.feedbackAndSupport, systemImage: "envelope")
                .tint(.saes)
        }
    }
}
