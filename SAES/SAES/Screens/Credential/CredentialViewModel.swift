import Foundation
import SwiftUI
import Toast

@MainActor
final class CredentialViewModel: ObservableObject {
    @Published var profilePicture: Data?
    @Published var credentialModel: CredentialModel?
    @Published var credentialWebData: CredentialWebData?
    @Published var showScanner: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var exportedImage: UIImage?

    private let storage: CredentialStorageClient
    private let cacheManager: CredentialCacheClient
    private let credentialParser: CredentialParser
    private let schoolCodeProvider: () -> String
    private let logger = Logger(logLevel: .error)

    var hasCredential: Bool {
        credentialModel != nil
    }

    var studentName: String {
        credentialWebData?.studentName ?? ""
    }

    var studentID: String {
        credentialWebData?.studentID ?? ""
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

    var cctCode: String {
        credentialWebData?.cctCode ?? ""
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
        credentialParser: CredentialParser = CredentialParser(),
        schoolCodeProvider: @escaping () -> String = { UserDefaults.schoolCode }
    ) {
        self.storage = storage
        self.cacheManager = cacheManager
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
            ToastManager.shared.toastToPresent = Toast(
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                color: .red,
                message: Localization.credentialLoadFailed
            )
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "CredentialViewModel")
        }
    }

    func processScannedQR(_ code: String) async {
        guard isValidCredentialURL(code) else {
            ToastManager.shared.toastToPresent = Toast(
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                color: .red,
                message: Localization.invalidCredentialURL
            )
            return
        }
        saveQRData(code)
        await fetchCredentialWebData()
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

    private func setCredentialWebData(_ data: CredentialWebData) {
        credentialWebData = data
        if let base64 = data.profilePictureBase64 {
            profilePicture = base64.convertDataURIToData()
        }
    }

    private func isValidCredentialURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let host = url.host else { return false }
        return host.contains("ipn.mx")
    }

    private func persistWebData(_ webData: CredentialWebData) {
        guard let model = credentialModel else { return }
        let code = schoolCodeProvider()
        let dataToSave: CredentialWebData
        if webData.profilePictureBase64 == nil, let existing = credentialWebData?.profilePictureBase64 {
            dataToSave = CredentialWebData(
                studentID: webData.studentID,
                studentName: webData.studentName,
                curp: webData.curp,
                career: webData.career,
                school: webData.school,
                cctCode: webData.cctCode,
                isEnrolled: webData.isEnrolled,
                statusText: webData.statusText,
                profilePictureBase64: existing
            )
        } else {
            dataToSave = webData
        }
        cacheManager.save(code, data: dataToSave)
        let updated = CredentialModel(
            qrData: model.qrData,
            scannedDate: model.scannedDate,
            schoolCode: model.schoolCode,
            webData: dataToSave
        )
        storage.saveCredential(code, data: updated)
        credentialModel = updated
    }
}
