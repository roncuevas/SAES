import Foundation

extension RealmManager {
    static func getUser(for user: String, 
                        at school: String = UserDefaults.standard.getSchoolCode()) -> UserSessionModel? {
        return RealmManager.shared.getObjects(type: UserSessionModel.self)?.first{ $0.school == school && $0.user == user }
    }
}
