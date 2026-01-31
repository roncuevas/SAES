import Foundation

final class ScheduleViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var pdfURL: URL?
    @Published var loadingState: SAESLoadingState = .idle

    private var pdfDataSource: SAESDataSource = SchedulePDFDataSource()
    private var pdfTempURL: URL {
        let temporalDirectory = FileManager.default.temporaryDirectory
        return temporalDirectory.appendingPathComponent("comprobante", conformingTo: .pdf)
    }

    func getPDFData() async {
        await setLoadingState(.loading)
        do {
            let data = try await pdfDataSource.fetch()
            let tempURL = try saveTemporalPDF(data: data)
            await setPDFUrl(tempURL)
            await setLoadingState(.loaded)
        } catch {
            debugPrint(error.localizedDescription)
            await setLoadingState(.error)
        }
    }

    func setLastPDFUrl() {
        self.pdfURL = pdfTempURL
    }

    private func saveTemporalPDF(data: Data) throws -> URL {
        try data.write(to: pdfTempURL, options: .atomic)
        return pdfTempURL
    }

    @MainActor
    private func setPDFUrl(_ url: URL) {
        self.pdfURL = url
    }
}
