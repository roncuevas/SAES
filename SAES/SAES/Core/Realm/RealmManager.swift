import Foundation
import RealmSwift

class RealmManager {
    static let shared: RealmManager = RealmManager()
    let realm: Realm
    
    private init() {
        #if DEBUG
        // swiftlint:disable:next force_try
        realm = try! Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true))
        #else
        // swiftlint:disable:next force_try
        realm = try! Realm()
        #endif
    }
    
    func addObject(object: Object) {
        realm.writeAsync {
            self.realm.add(object)
        }
    }
    
    func getObjects<T: Object>(type: T.Type) -> Results<T>? {
        return realm.objects(T.self)
    }
    
    func deleteObject<Element: ObjectBase>(object: List<Element>) {
        try? realm.write {
            self.realm.delete(object)
        }
    }
    
    func deleteAll() {
        realm.writeAsync {
            self.realm.deleteAll()
        }
    }
    
    func updateObject(completion: @escaping () -> Void) {
        realm.writeAsync {
            completion()
        }
    }
    
    func writeObject(completion: @escaping (Realm) -> Void) {
        realm.writeAsync {
            completion(self.realm)
        }
    }
}
