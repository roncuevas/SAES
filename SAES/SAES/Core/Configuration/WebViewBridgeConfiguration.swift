import Foundation

struct WebViewBridgeConfiguration {
    let messageKeys: [String]
    let taskIDs: [String]
    let dayNames: [String]
    let jsFunctions: [String: String]

    static let shared = WebViewBridgeConfiguration(
        messageKeys: ["imageData", "profileImageData", "isErrorPage", "isErrorCaptcha", "schedule", "grades", "kardex"],
        taskIDs: ["loginForm", "personalData", "isErrorPage", "schedule", "grades", "kardex", "getCaptchaImage", "reloadCaptcha", "getProfileImage"],
        dayNames: ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado"],
        jsFunctions: [
            "getCaptchaImage": "window.SAES.getCaptchaImage();",
            "getProfileImage": "window.SAES.getProfileImage();",
            "reloadCaptcha": "window.SAES.reloadCaptcha();",
            "personalData": "window.SAES.extractPersonalData();",
            "isErrorPage": "window.SAES.checkErrorPage();",
            "schedule": "window.SAES.extractSchedule();",
            "grades": "window.SAES.extractGrades();",
            "kardex": "window.SAES.extractKardex();",
            "loginFormTemplate": "window.SAES.fillLoginForm(\"{boleta}\", \"{password}\", \"{captcha}\");"
        ]
    )
}
