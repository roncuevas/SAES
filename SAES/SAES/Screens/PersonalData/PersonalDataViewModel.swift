import Foundation

class PersonalDataViewModel: ObservableObject, SAESLoadingStateManager {
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
        self.logger = Logger(logLevel: .error)
    }

    func getData(refresh: Bool) async {
        if refresh { await setPersonalData([:]) }
        do {
            try await performLoading {
                let data = try await self.dataSource.fetch()
                let parsed = try self.parser.parse(data: data)
                await self.setPersonalData(parsed)
            }
        } catch {
            logger.log(
                level: .error,
                message: "\(error.localizedDescription)",
                source: "PersonalDataViewModel"
            )
        }
    }

    func getProfilePicture() async {
        do {
            let data = try await profilePictureDataSource.fetch()
            await setProfilePicture(data)
        } catch {
            logger.log(
                level: .error,
                message: "\(error.localizedDescription)",
                source: "PersonalDataViewModel"
            )
        }
    }

    @MainActor
    func setProfilePicture(_ data: Data) {
        self.profilePicture = data
    }

    @MainActor
    func setPersonalData(_ personalData: [String: String]) {
        self.personalData = personalData
    }
}
