import Foundation

class PersonalDataViewModel: ObservableObject, SAESLoadingStateManager {
    @Published var loadingState: SAESLoadingState = .idle
    @Published var personalData: PersonalDataModel?
    @Published var profilePicture: Data?
    private var dataSource: SAESDataSource = PersonalDataDataSource()
    private var profilePictureDataSource: SAESDataSource = ProfilePictureDataSource()
    private var parser: PersonalDataParser = PersonalDataParser()
    private let logger: Logger = Logger(logLevel: .error)

    func getData(refresh: Bool) async {
        if refresh { await setPersonalData(nil) }
        do {
            await setLoadingState(.loading)
            let data = try await dataSource.fetch()
            let parsed = try parser.parse(data: data)
            await setPersonalData(parsed)
            await setLoadingState(.loaded)
        } catch {
            await setLoadingState(.error)
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
    func setPersonalData(_ personalData: PersonalDataModel?) {
        self.personalData = personalData
    }
}
