import SwiftUI

struct NavigationViewModifier: ViewModifier {
    let title: String
    let titleDisplayMode: NavigationBarItem.TitleDisplayMode
    let background: Visibility
    let backButtonHidden: Bool

    func body(content: Content) -> some View {
        content
            .toolbarBackground(background, for: .navigationBar)
            .navigationBarTitleDisplayMode(titleDisplayMode)
            .navigationTitle(title)
            .navigationBarBackButtonHidden(backButtonHidden)
    }
}
