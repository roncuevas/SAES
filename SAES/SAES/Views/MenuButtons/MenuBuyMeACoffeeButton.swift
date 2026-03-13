import SwiftUI

struct MenuBuyMeACoffeeButton: View {
    @Binding var showPaywall: Bool

    var body: some View {
        Button {
            showPaywall = true
        } label: {
            Label(Localization.buyMeACoffee, systemImage: "cup.and.saucer.fill")
                .tint(.saes)
        }
    }
}
