import Foundation
import RealmSwift

class RealmManager {
    static let shared: RealmManager = RealmManager()
    let realm: Realm?
    
    private init() {
        realm = try? Realm()
    }
    
    func addObject(object: Object) {
        guard let realm else { return }
        realm.writeAsync {
            realm.add(object)
        }
    }
    
    func getObjects<T: Object>(type: T.Type) -> Results<T>? {
        return realm?.objects(T.self)
    }
    
    func deleteObject<Element: ObjectBase>(object: List<Element>) {
        guard let realm else { return }
        try? realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll() {
        guard let realm else { return }
        realm.writeAsync {
            realm.deleteAll()
        }
    }
    
    func updateObject(completion: @escaping () -> Void) {
        guard let realm else { return }
        realm.writeAsync {
            completion()
        }
    }
    
    func writeObject(completion: @escaping (Realm) -> Void) {
        guard let realm else { return }
        realm.writeAsync {
            completion(realm)
        }
    }
}
