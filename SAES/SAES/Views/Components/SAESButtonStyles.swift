import SwiftUI

struct SAESFilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.saes)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SAESOutlinedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .foregroundStyle(.saes)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.saes, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

extension ButtonStyle where Self == SAESFilledButtonStyle {
    static var filledStyle: SAESFilledButtonStyle { SAESFilledButtonStyle() }
}

extension ButtonStyle where Self == SAESOutlinedButtonStyle {
    static var outlinedStyle: SAESOutlinedButtonStyle { SAESOutlinedButtonStyle() }
}
