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
        self.logger = Logger(logLevel: .error)
    }

    func getKardex() async {
        let dataSource = self.dataSource
        let parser = self.parser
        do {
            let data = try await performLoading {
                try await dataSource.fetch()
            }
            self.kardexModel = try parser.parseKardex(data)
        } catch {
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "KardexViewModel")
        }
    }
}
