import Foundation

final class ScheduleViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var pdfURL: URL?
    @Published var loadingState: SAESLoadingState = .idle

    private var pdfDataSource: SAESDataSource = SchedulePDFDataSource()
    private let logger = Logger(logLevel: .error)
    private var pdfTempURL: URL {
        let temporalDirectory = FileManager.default.temporaryDirectory
        return temporalDirectory.appendingPathComponent("comprobante", conformingTo: .pdf)
    }

    func getPDFData() async {
        do {
            try await performLoading {
                let data = try await self.pdfDataSource.fetch()
                let tempURL = try self.saveTemporalPDF(data: data)
                await self.setPDFUrl(tempURL)
            }
        } catch {
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "ScheduleViewModel")
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
