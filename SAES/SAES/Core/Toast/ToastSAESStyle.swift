import Foundation
import SwiftUI
import Toast

struct ToastSAESStyle: ToastStyle {
    func makeBody(configuration: ToastStyleConfiguration) -> some View {
        HStack(spacing: 10) {
            configuration.toast.icon
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(configuration.toast.color)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).fill(configuration.toast.color.opacity(0.3)))

            Text(configuration.toast.message)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Spacer(minLength: .zero)

            configuration.trailingView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(configuration.toast.color, lineWidth: 1)
        )
        .cornerRadius(12)
        .padding()
    }
}
