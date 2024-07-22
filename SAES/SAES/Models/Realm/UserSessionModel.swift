import Foundation
import RealmSwift

class UserSessionModel: Object {
    @Persisted var school: String
    @Persisted var user: String
    @Persisted var password: String
    @Persisted var cookies: List<CookieModel>
    
    convenience init(school: String, 
                     user: String,
                     password: String,
                     cookies: List<CookieModel>) {
        self.init()
        self.school = school
        self.user = user
        self.password = password
        self.cookies = cookies
    }
    
    static func getAll() -> Results<UserSessionModel>? {
        return RealmManager.shared.getObjects(type: UserSessionModel.self)
    }
    
    static func getFirst() -> UserSessionModel? {
        return RealmManager.shared.getObjects(type: UserSessionModel.self)?.first
    }
}

extension UserSessionModel {
    func update(completion: @escaping (UserSessionModel) -> Void) {
        RealmManager.shared.updateObject {
            completion(self)
        }
    }
}
