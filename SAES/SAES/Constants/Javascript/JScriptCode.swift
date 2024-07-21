import Foundation

enum JScriptCode {
    case common
    case getCaptchaImage
    case loginForm(String, String, String)
    case isLogged
    case reloadCaptcha
    case logout
    case personalData
    case isErrorPage
    case getProfileImage
    case schedule
    case grades
    case kardex
    
    var rawValue: String {
        switch self {
        case .common:
            JavaScriptConstants.common
        case .getCaptchaImage:
            JavaScriptConstants.getCaptchaImage
        case .loginForm(let boleta, let password, let captcha):
            JavaScriptConstants.loginForm(boleta: boleta, password: password, captcha: captcha)
        case .isLogged:
            JavaScriptConstants.isLogged
        case .reloadCaptcha:
            JavaScriptConstants.reloadCaptcha
        case .logout:
            JavaScriptConstants.logout
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
