import QuickLook
import SwiftUI

struct ProfilePicturePreviewModifier: ViewModifier {
    let imageData: Data?
    @Binding var isPresented: Bool
    @State private var previewURL: URL?
    @State private var cachedFileURL: URL?

    private static let tempFileURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("profile_picture.jpg")

    func body(content: Content) -> some View {
        content
            .onAppear {
                cacheImage(imageData)
            }
            .onChange(of: imageData) { _, newData in
                cacheImage(newData)
            }
            .onChange(of: isPresented) { _, newValue in
                guard newValue else { return }
                guard let cachedFileURL else {
                    isPresented = false
                    return
                }
                previewURL = cachedFileURL
            }
            .quickLookPreview($previewURL)
            .onChange(of: previewURL) { _, newValue in
                if newValue == nil {
                    isPresented = false
                }
            }
    }

    private func cacheImage(_ data: Data?) {
        guard let data, !data.isEmpty else {
            cachedFileURL = nil
            return
        }
        try? data.write(to: Self.tempFileURL)
        cachedFileURL = Self.tempFileURL
    }
}
