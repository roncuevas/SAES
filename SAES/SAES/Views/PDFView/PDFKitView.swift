import PDFKit
import SwiftUI

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        let document = PDFDocument(data: data)
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update the view if needed, e.g., if the URL changes
        // For a static URL, this method might remain empty.
    }
}
