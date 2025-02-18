import SwiftUI
import UIKit

struct CustomTextField: View {
    @State private var isPasswordVisible: Bool = false
    @Binding var text: String
    let placeholder: String
    let imageTF: Image?
    let isPassword: Bool
    let keyboardType: UIKeyboardType
    let color: Color?

    @Environment(\.colorScheme) private var colorScheme

    init(
        text: Binding<String>, placeholder: String, imageTF: Image? = nil,
        isPassword: Bool = false, keyboardType: UIKeyboardType = .default,
        color: Color? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.imageTF = imageTF
        self.isPassword = isPassword
        self.keyboardType = keyboardType
        self.color = color
    }

    var computedColor: Color {
        color ?? (colorScheme == .dark ? .white : .black)
    }

    var body: some View {
        ZStack {
            HStack {
                if let imageTF = imageTF {
                    imageTF
                        .foregroundColor(computedColor)
                        .scaleEffect(text.isEmpty ? 1 : 1.2)
                        .animation(.easeInOut, value: text.isEmpty)
                }

                if isPassword && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textContentType(.password)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }

                if !text.isEmpty {
                    if isPassword {
                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible
                                  ? "eye.slash.fill" : "eye.fill")
                                .font(.title2)
                                .foregroundColor(computedColor)
                        }
                    } else {
                        Button {
                            text.removeAll()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(computedColor)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: 45, maxHeight: 45)

            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(computedColor, lineWidth: 2)
                    .shadow(color: computedColor.opacity(0.4), radius: 5)
                    .frame(maxWidth: .infinity, minHeight: 45, maxHeight: 45)

                Text(placeholder)
                    .foregroundColor(computedColor)
                    .bold()
                    .padding(.horizontal, 5)
                    .background(
                        colorScheme == .dark ? Color.black : Color.white
                    )
                    .frame(
                        maxWidth: .infinity, minHeight: 65, maxHeight: 65,
                        alignment: .topLeading
                    )
                    .padding(.leading, 35)
            }
            .frame(maxWidth: .infinity, minHeight: 45, maxHeight: 45)
        }
        .frame(maxWidth: .infinity, minHeight: 65, maxHeight: 65)
    }
}

#Preview {
    CustomTextField(
        text: .constant("username"), placeholder: "Username",
        imageTF: Image(systemName: "person"), isPassword: false,
        keyboardType: .default, color: .saesColorRed)
}

#Preview("Password") {
    CustomTextField(
        text: .constant("username"), placeholder: "Username",
        imageTF: Image(systemName: "person"), isPassword: true,
        keyboardType: .default, color: .saesColorRed)
}
