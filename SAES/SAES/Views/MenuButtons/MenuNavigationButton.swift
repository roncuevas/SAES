import AppRouter
import SwiftUI

struct MenuNavigationButton: View {
    let title: String
    let icon: String
    let destination: AppDestination
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Button {
            router.navigateTo(destination)
        } label: {
            Label(title, systemImage: icon)
                .tint(.saes)
        }
    }
}
