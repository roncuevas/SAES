import Foundation
import SwiftUI

@MainActor
final class CredentialViewModel: ObservableObject, SAESLoadingStateManager {
    @Published var loadingState: SAESLoadingState = .idle
    @Published var personalData: [String: String] = [:]
    @Published var profilePicture: Data?
    @Published var credentialModel: CredentialModel?
    @Published var credentialWebData: CredentialWebData?
    @Published var showScanner: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var exportedImage: UIImage?

    private let storage: CredentialStorageClient
    private let cacheManager: CredentialCacheClient
    private let personalDataSource: SAESDataSource
    private let profilePictureDataSource: SAESDataSource
    private let personalDataParser: PersonalDataParser
    private let credentialParser: CredentialParser
    private let schoolCodeProvider: () -> String
    private let logger = Logger(logLevel: .error)

    var hasCredential: Bool {
        credentialModel != nil
    }

    var studentName: String {
        credentialWebData?.studentName ?? personalData["name"] ?? ""
    }

    var studentID: String {
        credentialWebData?.studentID ?? personalData["studentID"] ?? ""
    }

    var campus: String {
        personalData["campus"] ?? ""
    }

    var schoolName: String {
        if let webSchool = credentialWebData?.school, !webSchool.isEmpty {
            return webSchool
        }
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
        let name = studentName
        let components = name.split(separator: " ")
        let letters = components.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    var career: String {
        credentialWebData?.career ?? ""
    }

    var isEnrolled: Bool {
        credentialWebData?.isEnrolled ?? false
    }

    var validityText: String {
        guard let webData = credentialWebData else {
            return ""
        }
        if webData.isEnrolled {
            return Localization.enrolled
        } else {
            return Localization.notEnrolled
        }
    }

    init(
        storage: CredentialStorageClient = CredentialStorageAdapter(),
        cacheManager: CredentialCacheClient = CredentialCacheManager(),
        personalDataSource: SAESDataSource = PersonalDataDataSource(),
        profilePictureDataSource: SAESDataSource = ProfilePictureDataSource(),
        personalDataParser: PersonalDataParser = PersonalDataParser(),
        credentialParser: CredentialParser = CredentialParser(),
        schoolCodeProvider: @escaping () -> String = { UserDefaults.schoolCode }
    ) {
        self.storage = storage
        self.cacheManager = cacheManager
        self.personalDataSource = personalDataSource
        self.profilePictureDataSource = profilePictureDataSource
        self.personalDataParser = personalDataParser
        self.credentialParser = credentialParser
        self.schoolCodeProvider = schoolCodeProvider
    }

    func loadSavedCredential() {
        let code = schoolCodeProvider()
        credentialModel = storage.loadCredential(code)

        if let cached = cacheManager.load(code) {
            setCredentialWebData(cached)
            return
        }
        if let webData = credentialModel?.webData {
            setCredentialWebData(webData)
            cacheManager.save(code, data: webData)
        }
    }

    func fetchCredentialWebData() async {
        guard let qrURL = credentialModel?.qrData,
              qrURL.hasPrefix("http") else { return }

        do {
            let dataSource = CredentialDataSource(qrURL: qrURL)
            let data = try await dataSource.fetch()
            let parsed = try credentialParser.parse(data: data)
            setCredentialWebData(parsed)
            persistWebData(parsed)
        } catch {
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "CredentialViewModel")
        }
    }

    func fetchStudentData() async {
        do {
            try await performLoading {
                let data = try await self.personalDataSource.fetch()
                let parsed = try self.personalDataParser.parse(data: data)
                self.setPersonalData(parsed)
            }
        } catch {
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "CredentialViewModel")
        }
    }

    func fetchProfilePicture() async {
        do {
            let data = try await profilePictureDataSource.fetch()
            setProfilePicture(data)
        } catch {
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "CredentialViewModel")
        }
    }

    func saveQRData(_ qrString: String) {
        let code = schoolCodeProvider()
        let model = CredentialModel(
            qrData: qrString,
            scannedDate: Date(),
            schoolCode: code,
            webData: nil
        )
        storage.saveCredential(code, data: model)
        credentialModel = model
    }

    func deleteCredential() {
        let code = schoolCodeProvider()
        storage.deleteCredential(code)
        cacheManager.delete(code)
        credentialModel = nil
        credentialWebData = nil
    }

    func exportCard(_ image: UIImage) {
        exportedImage = image
        showShareSheet = true
    }

    private func setPersonalData(_ data: [String: String]) {
        personalData = data
    }

    private func setProfilePicture(_ data: Data) {
        profilePicture = data
    }

    private func setCredentialWebData(_ data: CredentialWebData) {
        credentialWebData = data
        if let base64 = data.profilePictureBase64 {
            profilePicture = base64.convertDataURIToData()
        }
    }

    private func persistWebData(_ webData: CredentialWebData) {
        guard let model = credentialModel else { return }
        let code = schoolCodeProvider()
        cacheManager.save(code, data: webData)
        let updated = CredentialModel(
            qrData: model.qrData,
            scannedDate: model.scannedDate,
            schoolCode: model.schoolCode,
            webData: webData
        )
        storage.saveCredential(code, data: updated)
        credentialModel = updated
    }
}
