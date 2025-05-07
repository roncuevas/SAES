import Foundation

enum JScriptCode {
    case getCaptchaImage
    case loginForm(String, String, String)
    case reloadCaptcha
    case personalData
    case isErrorPage
    case getProfileImage
    case schedule
    case grades
    case kardex
    
    var value: String {
        switch self {
        case .getCaptchaImage:
            JavaScriptConstants.getCaptchaImage
        case .loginForm(let boleta, let password, let captcha):
            JavaScriptConstants.loginForm(boleta: boleta, password: password, captcha: captcha)
        case .reloadCaptcha:
            JavaScriptConstants.reloadCaptcha
        case .personalData:
            JavaScriptConstants.personalData
        case .isErrorPage:
            JavaScriptConstants.isErrorPage
        case .getProfileImage:
            JavaScriptConstants.getProfileImage
        case .schedule:
            JavaScriptConstants.schedule
        case .grades:
            JavaScriptConstants.grades
        case .kardex:
            JavaScriptConstants.kardex
        }
    }
}
