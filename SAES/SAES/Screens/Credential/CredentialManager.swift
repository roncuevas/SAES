import Foundation

struct CredentialManager {
    private let storage: CredentialStorageClient
    private let cacheManager: CredentialCacheClient

    init(storage: CredentialStorageClient = CredentialStorageAdapter(),
         cacheManager: CredentialCacheClient = CredentialCacheManager()) {
        self.storage = storage
        self.cacheManager = cacheManager
    }

    func load(for schoolCode: String) -> (model: CredentialModel?, webData: CredentialWebData?) {
        let model = storage.loadCredential(schoolCode)
        if let cached = cacheManager.load(schoolCode) {
            return (model, cached)
        }
        if let webData = model?.webData {
            cacheManager.save(schoolCode, data: webData)
            return (model, webData)
        }
        return (model, nil)
    }

    func save(qrData: String, schoolCode: String) -> CredentialModel {
        let model = CredentialModel(qrData: qrData, scannedDate: Date(), schoolCode: schoolCode, webData: nil)
        storage.saveCredential(schoolCode, data: model)
        return model
    }

    func persist(model: CredentialModel, webData: CredentialWebData, existingProfilePicture: String?) -> CredentialModel {
        let code = model.schoolCode
        let dataToSave: CredentialWebData
        if webData.profilePictureBase64 == nil, let existing = existingProfilePicture {
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
            schoolCode: code,
            webData: dataToSave
        )
        storage.saveCredential(code, data: updated)
        return updated
    }

    func delete(for schoolCode: String) {
        storage.deleteCredential(schoolCode)
        cacheManager.delete(schoolCode)
    }
}
