import Foundation

@MainActor
final class ScheduleReceiptManager: ObservableObject {
    static let shared = ScheduleReceiptManager()

    // MARK: - Constants

    static let icon = "doc.text"
    private static let fileSuffix = "_comprobante"
    private static let logSource = "ScheduleReceiptManager"

    // MARK: - Published state

    @Published var pdfURL: URL?
    @Published private(set) var hasCachedPDF: Bool = false

    // MARK: - Dependencies

    private let dataSource: SAESDataSource
    private let storage: LocalStorageClient
    private let logger = Logger(logLevel: .info)
    private var downloadTask: Task<Void, Never>?

    init(dataSource: SAESDataSource = SchedulePDFDataSource(),
         storage: LocalStorageClient = LocalStorageAdapter()) {
        self.dataSource = dataSource
        self.storage = storage
    }

    // MARK: - File management

    private var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    private var currentStudentID: String? {
        storage.loadUser(UserDefaults.schoolCode)?.studentID
    }

    private func pdfFileURL(for studentID: String) -> URL {
        cachesDirectory.appendingPathComponent("\(studentID)\(Self.fileSuffix)", conformingTo: .pdf)
    }

    var fileName: String? {
        guard let studentID = currentStudentID else { return nil }
        return "\(studentID)\(Self.fileSuffix).pdf"
    }

    // MARK: - State queries

    func refreshCacheState() {
        guard let studentID = currentStudentID else {
            hasCachedPDF = false
            return
        }
        let path = pdfFileURL(for: studentID).path
        hasCachedPDF = FileManager.default.fileExists(atPath: path)
    }

    // MARK: - Actions

    func showCachedPDF() {
        guard let studentID = currentStudentID else {
            logger.log(level: .warning, message: "No hay usuario para mostrar comprobante", source: Self.logSource)
            return
        }
        let url = pdfFileURL(for: studentID)
        guard FileManager.default.fileExists(atPath: url.path) else {
            logger.log(level: .warning, message: "No existe comprobante cacheado para \(studentID)", source: Self.logSource)
            return
        }
        pdfURL = url
        logger.log(level: .info, message: "Mostrando comprobante cacheado de \(studentID)", source: Self.logSource)
    }

    func getPDFData() async {
        guard downloadTask == nil else { return }
        pdfURL = nil
        downloadTask = Task {
            defer { downloadTask = nil }
            let studentID = await UserSessionManager.shared.currentUser()?.studentID
            guard let studentID else {
                logger.log(level: .error, message: "No se pudo obtener la boleta del usuario", source: Self.logSource)
                return
            }
            let fileURL = pdfFileURL(for: studentID)
            do {
                let data = try await dataSource.fetch()
                try await Task.detached(priority: .userInitiated) {
                    try data.write(to: fileURL, options: .atomic)
                }.value
                pdfURL = fileURL
                hasCachedPDF = true
                logger.log(level: .info, message: "Comprobante descargado para \(studentID)", source: Self.logSource)
            } catch {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    pdfURL = fileURL
                    logger.log(level: .warning, message: "Sin conexión, mostrando comprobante guardado de \(studentID)", source: Self.logSource)
                } else {
                    logger.log(level: .error, message: "Error al obtener comprobante: \(error.localizedDescription)", source: Self.logSource)
                }
            }
        }
        await downloadTask?.value
    }

    func deleteReceipt() {
        guard let studentID = currentStudentID else { return }
        let url = pdfFileURL(for: studentID)
        try? FileManager.default.removeItem(at: url)
        pdfURL = nil
        hasCachedPDF = false
        logger.log(level: .info, message: "Comprobante eliminado de \(studentID)", source: Self.logSource)
    }
}
