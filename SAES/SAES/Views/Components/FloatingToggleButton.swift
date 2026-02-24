import SwiftUI

struct FloatingToggleButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.saesOnSurface))
                .padding(14)
                .background(
                    Color(.floatingButtonBackground),
                    in: .circle
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
    }
}
