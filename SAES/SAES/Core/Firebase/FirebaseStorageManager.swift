@preconcurrency import FirebaseStorage
import Foundation

final class FirebaseStorageManager: @unchecked Sendable {
    private let storageReference = Storage.storage().reference()

    // MARK: - Upload image to Firebase Storage
    func uploadToStorage(_ data: Data, path: String) async throws -> URL {
        let storageRef = storageReference.child(path)
        _ = try await storageRef.putDataAsync(data, metadata: nil)
        return try await storageRef.downloadURL()
    }
}
