import Foundation

final class ScheduleViewModel: ObservableObject {
    @Published var pdfURL: URL?
    @Published var pdfState: SAESLoadingState = .idle

    var pdfDataSource: SAESDataSource = SchedulePDFDataSource()
    private var pdfTempURL: URL {
        let temporalDirectory = FileManager.default.temporaryDirectory
        return temporalDirectory.appendingPathComponent("comprobante", conformingTo: .pdf)
    }

    func getPDFData() {
        Task {
            await updatePDFState(.loading)
            do {
                let data = try await pdfDataSource.fetch()
                let tempURL = try saveTemporalPDF(data: data)
                await updatePDFUrl(tempURL)
                await updatePDFState(.loaded)
            } catch {
                debugPrint(error.localizedDescription)
                await updatePDFState(.error)
            }
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
    private func updatePDFUrl(_ url: URL) {
        self.pdfURL = url
    }

    @MainActor
    private func updatePDFState(_ state: SAESLoadingState) {
        self.pdfState = state
    }
}
