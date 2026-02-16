import Foundation

@MainActor
final class PersonalDataViewModel: ObservableObject, SAESLoadingStateManager {
    @Published var loadingState: SAESLoadingState = .idle
    @Published var personalData: [String: String]
    @Published var profilePicture: Data?
    private var dataSource: SAESDataSource
    private var profilePictureDataSource: SAESDataSource
    private var parser: PersonalDataParser
    private let logger: Logger

    subscript(key: String) -> String? {
        get { personalData[key] }
        set { personalData[key] = newValue }
    }

    init(dataSource: SAESDataSource = PersonalDataDataSource(),
         profilePictureDataSource: SAESDataSource = ProfilePictureDataSource(),
         parser: PersonalDataParser = PersonalDataParser()) {
        self.loadingState = .idle
        self.personalData = [:]
        self.profilePicture = nil
        self.dataSource = dataSource
        self.profilePictureDataSource = profilePictureDataSource
        self.parser = parser
        self.logger = Logger(logLevel: .info)
    }

    func getData(refresh: Bool) async {
        if refresh { self.personalData = [:] }
        let dataSource = self.dataSource
        let parser = self.parser
        do {
            let data = try await performLoading {
                try await dataSource.fetch()
            }
            let parsed = try parser.parse(data: data)
            self.personalData = parsed
            if parsed.isEmpty {
                setLoadingState(.empty)
                logger.log(level: .warning, message: "Sin datos personales", source: "PersonalDataViewModel")
            } else {
                logger.log(level: .info, message: "Datos personales obtenidos: \(parsed.count) campos", source: "PersonalDataViewModel")
            }
        } catch {
            setLoadingState(.empty)
            logger.log(level: .error, message: "Error al obtener datos personales: \(error.localizedDescription)", source: "PersonalDataViewModel")
        }
    }

    func getProfilePicture() async {
        do {
            let data = try await profilePictureDataSource.fetch()
            self.profilePicture = data
        } catch {
            logger.log(
                level: .error,
                message: "\(error.localizedDescription)",
                source: "PersonalDataViewModel"
            )
        }
    }

}
