import CustomKit
import SwiftUI

struct SAESCaptchaView: View {
    private let text: Binding<String>
    private let data: Binding<Data?>
    private let customColor: Color
    private let reloadAction: () -> Void

    init(text: Binding<String>,
         data: Binding<Data?>,
         customColor: Color,
         reloadAction: @escaping () -> Void) {
        self.text = text
        self.data = data
        self.customColor = customColor
        self.reloadAction = reloadAction
    }

    var body: some View {
        VStack(spacing: 16) {
            captchaView
            textInputView
        }
    }

    private var captchaView: some View {
        HStack {
            if let data = data.wrappedValue,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                    .clipShape(.rect(cornerRadius: 10))
            } else {
                VStack(spacing: 4) {
                    LottieLoadingView(size: 40)
                    Text(Localization.loadingCaptcha)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Button {
                reloadAction()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .font(.system(size: 24))
                    .fontWeight(.thin)
                    .tint(Color(.saesOnSurface))
            }
        }
    }

    private var textInputView: some View {
        CustomTextField(
            text: text,
            placeholder: "CAPTCHA",
            leadingImage: .init(systemName: "shield.checkerboard"),
            textAlignment: .topLeading,
            isPassword: false,
            keyboardType: .default,
            customColor: customColor,
            autocorrectionDisabled: true)
        .textFieldStyle(.textFieldUppercased)
    }
}
