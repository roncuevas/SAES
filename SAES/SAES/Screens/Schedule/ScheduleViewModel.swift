import Foundation

@MainActor
final class ScheduleViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var pdfURL: URL?
    @Published var loadingState: SAESLoadingState = .idle

    private var pdfDataSource: SAESDataSource
    private let logger: Logger

    init(pdfDataSource: SAESDataSource = SchedulePDFDataSource()) {
        self.pdfDataSource = pdfDataSource
        self.logger = Logger(logLevel: .error)
    }
    private var pdfTempURL: URL {
        let temporalDirectory = FileManager.default.temporaryDirectory
        return temporalDirectory.appendingPathComponent("comprobante", conformingTo: .pdf)
    }

    func getPDFData() async {
        let pdfDataSource = self.pdfDataSource
        do {
            let data = try await performLoading {
                try await pdfDataSource.fetch()
            }
            let tempURL = try self.saveTemporalPDF(data: data)
            self.pdfURL = tempURL
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

}
