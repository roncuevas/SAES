import SwiftUI

struct MenuBuyMeACoffeeButton: View {
    var body: some View {
        Button {
            // No action yet — placeholder
        } label: {
            Label(Localization.buyMeACoffee, systemImage: "cup.and.saucer.fill")
                .tint(.saes)
        }
    }
}
