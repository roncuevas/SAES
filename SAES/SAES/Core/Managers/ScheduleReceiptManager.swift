import Foundation

@MainActor
final class ScheduleReceiptManager: ObservableObject {
    static let shared = ScheduleReceiptManager()

    @Published var pdfURL: URL?

    private let dataSource: SAESDataSource
    private let storage: LocalStorageClient
    private let logger = Logger(logLevel: .info)

    init(dataSource: SAESDataSource = SchedulePDFDataSource(),
         storage: LocalStorageClient = LocalStorageAdapter()) {
        self.dataSource = dataSource
        self.storage = storage
    }

    // MARK: - File paths

    private var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    private var currentStudentID: String? {
        storage.loadUser(UserDefaults.schoolCode)?.studentID
    }

    private func pdfFileURL(for studentID: String) -> URL {
        cachesDirectory.appendingPathComponent("\(studentID)_comprobante", conformingTo: .pdf)
    }

    // MARK: - Public API

    var hasCachedPDF: Bool {
        guard let studentID = currentStudentID else { return false }
        return FileManager.default.fileExists(atPath: pdfFileURL(for: studentID).path)
    }

    func showCachedPDF() {
        guard let studentID = currentStudentID else { return }
        let url = pdfFileURL(for: studentID)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        pdfURL = url
    }

    func getPDFData() async {
        pdfURL = nil
        let studentID = await UserSessionManager.shared.currentUser()?.studentID
        guard let studentID else {
            logger.log(level: .error, message: "No se pudo obtener la boleta del usuario", source: "ScheduleReceiptManager")
            return
        }
        let fileURL = pdfFileURL(for: studentID)
        do {
            let data = try await dataSource.fetch()
            try data.write(to: fileURL, options: .atomic)
            pdfURL = fileURL
            logger.log(level: .info, message: "Comprobante descargado para \(studentID)", source: "ScheduleReceiptManager")
        } catch {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                pdfURL = fileURL
                logger.log(level: .warning, message: "Sin conexión, mostrando comprobante guardado", source: "ScheduleReceiptManager")
            } else {
                logger.log(level: .error, message: "Error al obtener comprobante: \(error.localizedDescription)", source: "ScheduleReceiptManager")
            }
        }
    }
}
