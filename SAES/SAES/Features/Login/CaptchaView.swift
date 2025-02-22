import SwiftUI

struct CaptchaView: View {
    @Environment(\.colorScheme) private var colorScheme
    private let data: Binding<Data?>
    private let reloadAction: () -> Void
    
    init(data: Binding<Data?>,
         reloadAction: @escaping () -> Void) {
        self.data = data
        self.reloadAction = reloadAction
    }
    
    var body: some View {
        HStack {
            if let data = data.wrappedValue,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                ProgressView()
                    .controlSize(.large)
                    .padding(.trailing)
            }
            Button {
                reloadAction()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .font(.system(size: 24))
                    .fontWeight(.thin)
                    .tint(colorScheme == .dark ? .white : .saesColorRed)
            }
        }
    }
}
