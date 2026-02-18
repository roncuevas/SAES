import SwiftUI
import CoreImage.CIFilterBuiltins

struct BarcodeGeneratorView: View {
    let data: String
    let height: CGFloat

    init(data: String, height: CGFloat = 60) {
        self.data = data
        self.height = height
    }

    var body: some View {
        if let image = generateBarcode(from: data) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(height: height)
        }
    }

    private func generateBarcode(from string: String) -> UIImage? {
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = Data(string.utf8)
        filter.quietSpace = 0

        guard let outputImage = filter.outputImage else { return nil }

        let scaleX = 2.0
        let scaleY = height / outputImage.extent.size.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
