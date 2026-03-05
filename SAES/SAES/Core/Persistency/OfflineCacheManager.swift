import Foundation
import LocalJSON

final class OfflineCacheManager: @unchecked Sendable {
    static let shared = OfflineCacheManager()

    private let logger = Logger(logLevel: .error)
    private let storage: CachedLocalJSON

    init(storage: CachedLocalJSON = CachedLocalJSON(wrapping: LocalJSON())) {
        self.storage = storage
    }

    func load(_ schoolCode: String) -> OfflineCache? {
        do {
            return try storage.getJSON(from: fileName(for: schoolCode), as: OfflineCache.self)
        } catch {
            if !(error is LocalJSONError) {
                logger.log(level: .error, message: "\(error)", source: "OfflineCacheManager")
            }
        }
        return nil
    }

    func save(_ schoolCode: String, data: OfflineCache) {
        do {
            try storage.writeJSON(data: data, to: fileName(for: schoolCode))
        } catch {
            logger.log(level: .error, message: "\(error)", source: "OfflineCacheManager")
        }
    }

    func saveGrades(_ schoolCode: String, grades: [Grupo]) {
        var cache = load(schoolCode) ?? OfflineCache(grades: [], kardex: nil, schedule: [], personalData: [:], lastUpdated: Date())
        cache.grades = grades
        cache.lastUpdated = Date()
        save(schoolCode, data: cache)
    }

    func saveKardex(_ schoolCode: String, kardex: KardexModel) {
        var cache = load(schoolCode) ?? OfflineCache(grades: [], kardex: nil, schedule: [], personalData: [:], lastUpdated: Date())
        cache.kardex = kardex
        cache.lastUpdated = Date()
        save(schoolCode, data: cache)
    }

    func savePersonalData(_ schoolCode: String, personalData: [String: String]) {
        var cache = load(schoolCode) ?? OfflineCache(grades: [], kardex: nil, schedule: [], personalData: [:], lastUpdated: Date())
        cache.personalData = personalData
        cache.lastUpdated = Date()
        save(schoolCode, data: cache)
    }

    func saveSchedule(_ schoolCode: String, schedule: [ScheduleItem]) {
        var cache = load(schoolCode) ?? OfflineCache(grades: [], kardex: nil, schedule: [], personalData: [:], lastUpdated: Date())
        cache.schedule = schedule
        cache.lastUpdated = Date()
        save(schoolCode, data: cache)
    }

    func delete(_ schoolCode: String) {
        do {
            try storage.delete(file: fileName(for: schoolCode))
        } catch {
            if !(error is LocalJSONError) {
                logger.log(level: .error, message: "\(error)", source: "OfflineCacheManager")
            }
        }
    }

    func hasCache(for schoolCode: String) -> Bool {
        load(schoolCode) != nil
    }

    private func fileName(for schoolCode: String) -> String {
        "offline_cache_\(schoolCode).json"
    }
}
