import Foundation

@MainActor
final class ScheduleReceiptManager: ObservableObject {
    static let shared = ScheduleReceiptManager()

    @Published var pdfURL: URL?

    private let dataSource: SAESDataSource
    private let logger = Logger(logLevel: .info)

    init(dataSource: SAESDataSource = SchedulePDFDataSource()) {
        self.dataSource = dataSource
    }

    var pdfTempURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("comprobante", conformingTo: .pdf)
    }

    var hasCachedPDF: Bool {
        FileManager.default.fileExists(atPath: pdfTempURL.path)
    }

    func getPDFData() async {
        pdfURL = nil
        do {
            let data = try await dataSource.fetch()
            try data.write(to: pdfTempURL, options: .atomic)
            pdfURL = pdfTempURL
            logger.log(level: .info, message: "Comprobante descargado", source: "ScheduleReceiptManager")
        } catch {
            if hasCachedPDF {
                pdfURL = pdfTempURL
                logger.log(level: .warning, message: "Sin conexión, mostrando comprobante guardado", source: "ScheduleReceiptManager")
            } else {
                logger.log(level: .error, message: "Error al obtener comprobante: \(error.localizedDescription)", source: "ScheduleReceiptManager")
            }
        }
    }
}
