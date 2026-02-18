import Foundation
import SwiftUI
import Toast

@MainActor
final class CredentialViewModel: ObservableObject {
    @Published var profileImage: UIImage?
    @Published var credentialModel: CredentialModel?
    @Published var credentialWebData: CredentialWebData?
    @Published var showScanner: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var showSchoolMismatchAlert: Bool = false
    @Published var exportedImage: UIImage?

    private let manager: CredentialManager
    private let credentialFetcher: (String) async throws -> CredentialWebData
    private let schoolCodeProvider: () -> String
    private let logger = Logger(logLevel: .error)
    private var pendingQRCode: String?
    private var pendingWebData: CredentialWebData?
    private var pendingSchoolData: SchoolData?

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

    var schoolAbbreviation: String {
        (credentialModel?.schoolCode ?? schoolCodeProvider()).uppercased()
    }

    private var currentSchoolCode: String {
        schoolCodeProvider()
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

    var isLoggedIn: Bool {
        UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.isLogged)
    }

    var mismatchSchoolName: String {
        pendingSchoolData?.name ?? ""
    }

    var mismatchMessage: String {
        let name = mismatchSchoolName
        if isLoggedIn {
            return String(format: Localization.schoolMismatchSaveMessage, name)
        } else {
            return String(format: Localization.schoolMismatchSwitchMessage, name, name)
        }
    }

    var mismatchButtonTitle: String {
        isLoggedIn ? Localization.saveCredential : Localization.switchSchool
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
        credentialFetcher: @escaping (String) async throws -> CredentialWebData = { qrURL in
            let parser = CredentialParser()
            let data = try await CredentialDataSource(qrURL: qrURL).fetch()
            return try parser.parse(data: data)
        },
        schoolCodeProvider: @escaping () -> String = { UserDefaults.schoolCode }
    ) {
        self.manager = CredentialManager(storage: storage, cacheManager: cacheManager)
        self.credentialFetcher = credentialFetcher
        self.schoolCodeProvider = schoolCodeProvider
    }

    func loadSavedCredential() {
        let code = currentSchoolCode
        let (model, webData) = manager.load(for: code)
        credentialModel = model
        if let webData {
            setCredentialWebData(webData)
        }
    }

    func fetchCredentialWebData() async {
        guard let qrURL = credentialModel?.qrData,
              qrURL.hasPrefix("http") else { return }

        do {
            let parsed = try await credentialFetcher(qrURL)
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

        do {
            let parsed = try await credentialFetcher(code)

            let currentCode = schoolCodeProvider()
            if let schoolData = SchoolMatcher.shared.detectSchool(from: parsed.school),
               schoolData.code.rawValue != currentCode {
                pendingQRCode = code
                pendingWebData = parsed
                pendingSchoolData = schoolData
                showSchoolMismatchAlert = true
            } else {
                saveQRData(code)
                setCredentialWebData(parsed)
                persistWebData(parsed)
            }
        } catch {
            ToastManager.shared.toastToPresent = Toast(
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                color: .red,
                message: Localization.credentialLoadFailed
            )
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "CredentialViewModel")
        }
    }

    func confirmSaveCredential() {
        guard let qrCode = pendingQRCode,
              let webData = pendingWebData,
              let schoolData = pendingSchoolData else { return }

        let isLoggedIn = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.isLogged)
        let targetCode = schoolData.code.rawValue

        if !isLoggedIn {
            UserDefaults.standard.set(targetCode, forKey: AppConstants.UserDefaultsKeys.schoolCode)
            UserDefaults.standard.set(schoolData.saes, forKey: AppConstants.UserDefaultsKeys.saesURL)
        }

        let model = manager.save(qrData: qrCode, schoolCode: targetCode)
        let persisted = manager.persist(model: model, webData: webData, existingProfilePicture: nil)

        pendingQRCode = nil
        pendingWebData = nil
        pendingSchoolData = nil

        if schoolCodeProvider() == targetCode {
            credentialModel = persisted
            setCredentialWebData(webData)
        }
    }

    func cancelSaveCredential() {
        pendingQRCode = nil
        pendingWebData = nil
        pendingSchoolData = nil
    }

    func saveQRData(_ qrString: String, schoolCode: String? = nil) {
        let code = schoolCode ?? currentSchoolCode
        credentialModel = manager.save(qrData: qrString, schoolCode: code)
    }

    func deleteCredential() {
        manager.delete(for: currentSchoolCode)
        credentialModel = nil
        credentialWebData = nil
        profileImage = nil
    }

    func exportCard(_ image: UIImage) {
        exportedImage = image
        showShareSheet = true
    }

    private func setCredentialWebData(_ data: CredentialWebData) {
        credentialWebData = data
        if let base64 = data.profilePictureBase64,
           let imageData = base64.convertDataURIToData() {
            profileImage = UIImage(data: imageData)
        }
    }

    private func isValidCredentialURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let host = url.host else { return false }
        return host.contains("ipn.mx")
    }

    private func persistWebData(_ webData: CredentialWebData) {
        guard let model = credentialModel else { return }
        credentialModel = manager.persist(
            model: model,
            webData: webData,
            existingProfilePicture: credentialWebData?.profilePictureBase64
        )
    }
}
