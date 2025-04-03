import Foundation
import FirebaseFirestore

final class FirestoreManager {
    private let defaultDB = Firestore.firestore()
    private let collectionName: String
    private var collectionReference: CollectionReference {
        defaultDB.collection(collectionName)
    }

    init(collectionName: String) {
        self.collectionName = collectionName
    }

    func checkIfDocumentExists(_ hash: String) async throws -> Bool {
        let docRef = collectionReference.document(hash)
        let snapshot = try await docRef.getDocument()
        return snapshot.exists
    }

    func saveDocument(id: String, data: [String: Any]) async throws {
        try await collectionReference.document(id).setData(data)
    }

    func saveCaptchaMetadata(hash: String, captchaText: String, imageURL: String) async throws {
        let data: [String: Any] = [
            "captchaText": captchaText,
            "imageURL": imageURL,
            "timestamp": FieldValue.serverTimestamp()
        ]
        try await collectionReference.document(hash).setData(data)
    }
}
