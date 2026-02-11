import Foundation
import SwiftUI

final class CredentialViewModel: ObservableObject, SAESLoadingStateManager {
    @Published var loadingState: SAESLoadingState = .idle
    @Published var personalData: [String: String] = [:]
    @Published var profilePicture: Data?
    @Published var credentialModel: CredentialModel?
    @Published var showScanner: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var exportedImage: UIImage?

    private let storage: CredentialStorageClient
    private let dataSource: SAESDataSource
    private let profilePictureDataSource: SAESDataSource
    private let parser: PersonalDataParser
    private let schoolCodeProvider: () -> String
    private let logger = Logger(logLevel: .error)

    var hasCredential: Bool {
        credentialModel != nil
    }

    var studentName: String {
        personalData["name"] ?? ""
    }

    var studentID: String {
        personalData["studentID"] ?? ""
    }

    var campus: String {
        personalData["campus"] ?? ""
    }

    var schoolName: String {
        let code = schoolCodeProvider()
        guard let schoolCode = SchoolCodes(rawValue: code) else { return code.uppercased() }
        if let data = UniversityConstants.schools[schoolCode] {
            return data.name
        }
        if let data = HighSchoolConstants.schools[schoolCode] {
            return data.name
        }
        return code.uppercased()
    }

    var initials: String {
        let components = studentName.split(separator: " ")
        let letters = components.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    var career: String {
        // Mock: to be parsed from QR URL in the future
        ""
    }

    var validityText: String {
        // Mock: to be parsed from QR URL in the future
        Localization.validUntil + " 2026"
    }

    init(
        storage: CredentialStorageClient = CredentialStorageAdapter(),
        dataSource: SAESDataSource = PersonalDataDataSource(),
        profilePictureDataSource: SAESDataSource = ProfilePictureDataSource(),
        parser: PersonalDataParser = PersonalDataParser(),
        schoolCodeProvider: @escaping () -> String = { UserDefaults.schoolCode }
    ) {
        self.storage = storage
        self.dataSource = dataSource
        self.profilePictureDataSource = profilePictureDataSource
        self.parser = parser
        self.schoolCodeProvider = schoolCodeProvider
    }

    func loadSavedCredential() {
        let code = schoolCodeProvider()
        credentialModel = storage.loadCredential(code)
    }

    func fetchStudentData() async {
        do {
            try await performLoading {
                let data = try await self.dataSource.fetch()
                let parsed = try self.parser.parse(data: data)
                await self.setPersonalData(parsed)
            }
        } catch {
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "CredentialViewModel")
        }
    }

    func fetchProfilePicture() async {
        do {
            let data = try await profilePictureDataSource.fetch()
            await setProfilePicture(data)
        } catch {
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "CredentialViewModel")
        }
    }

    func saveQRData(_ qrString: String) {
        let code = schoolCodeProvider()
        let model = CredentialModel(
            qrData: qrString,
            scannedDate: Date(),
            schoolCode: code
        )
        storage.saveCredential(code, data: model)
        credentialModel = model
    }

    func deleteCredential() {
        let code = schoolCodeProvider()
        storage.deleteCredential(code)
        credentialModel = nil
    }

    @MainActor
    func exportCard(_ image: UIImage) {
        exportedImage = image
        showShareSheet = true
    }

    @MainActor
    private func setPersonalData(_ data: [String: String]) {
        personalData = data
    }

    @MainActor
    private func setProfilePicture(_ data: Data) {
        profilePicture = data
    }
}
