import Foundation
import SwiftUI

struct PDFViewer: View {
    let data: Data

    @State private var showingExporter = false
    @State private var showingShare = false
    @State private var shareURL: URL?

    var body: some View {
        PDFKitView(data: data)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Compartir
                    Button {
                        if let url = writeTempPDF() {
                            shareURL = url
                            showingShare = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Compartir PDF")

                    // Guardar en Archivos
                    Button {
                        showingExporter = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                    .accessibilityLabel("Guardar PDF")
                }
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: PDFDataDocument(data: data),
                contentType: .pdf,
                defaultFilename: "documento"
            ) { _ in }
            .sheet(isPresented: $showingShare) {
                if let url = shareURL {
                    ShareSheet(activityItems: [url])
                }
            }
    }

    private func writeTempPDF() -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("compartir_documento.pdf")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
