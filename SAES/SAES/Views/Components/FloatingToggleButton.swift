import SwiftUI

struct FloatingToggleButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .padding(16)
                .background(.saes)
                .clipShape(.circle)
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        }
    }
}
