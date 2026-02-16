import Foundation

@MainActor
final class KardexViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState = .idle
    @Published var kardexModel: KardexModel?

    private var dataSource: SAESDataSource
    private var parser: KardexParser
    private let logger: Logger

    init(dataSource: SAESDataSource = KardexDataSource(),
         parser: KardexParser = KardexParser()) {
        self.dataSource = dataSource
        self.parser = parser
        self.logger = Logger(logLevel: .info)
    }

    func getKardex() async {
        let dataSource = self.dataSource
        let parser = self.parser
        do {
            let data = try await performLoading {
                try await dataSource.fetch()
            }
            let parsed = try parser.parseKardex(data)
            self.kardexModel = parsed
            if parsed.kardex?.isEmpty ?? true {
                setLoadingState(.empty)
                logger.log(level: .warning, message: "Sin datos de kárdex", source: "KardexViewModel")
            } else {
                logger.log(level: .info, message: "Kárdex obtenido: \(parsed.kardex?.count ?? 0) semestres", source: "KardexViewModel")
            }
        } catch {
            setLoadingState(.empty)
            logger.log(level: .error, message: "Error al obtener kárdex: \(error.localizedDescription)", source: "KardexViewModel")
        }
    }
}
