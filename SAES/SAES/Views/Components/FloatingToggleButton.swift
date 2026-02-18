import SwiftUI

struct FloatingToggleButton: View {
    let systemImage: String
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme == .dark ? .white : .saes)
                .padding(14)
                .background(
                    colorScheme == .dark ? Color.white.opacity(0.55) : Color(.systemBackground),
                    in: .circle
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
    }
}
