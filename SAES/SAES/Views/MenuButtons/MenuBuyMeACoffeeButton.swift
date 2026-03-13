import RevenueCatUI
import SwiftUI

struct MenuBuyMeACoffeeButton: View {
    @State private var showPaywall = false

    var body: some View {
        Button {
            showPaywall = true
        } label: {
            Label(Localization.buyMeACoffee, systemImage: "cup.and.saucer.fill")
                .tint(.saes)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
