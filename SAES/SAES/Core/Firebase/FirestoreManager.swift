import Foundation
@preconcurrency import FirebaseFirestore

final class FirestoreManager: @unchecked Sendable {
    private let defaultDB = Firestore.firestore()
    private let collectionName: String
    private var collectionReference: CollectionReference {
        defaultDB.collection(collectionName)
    }

    var timestamp: FieldValue {
        FieldValue.serverTimestamp()
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
}
