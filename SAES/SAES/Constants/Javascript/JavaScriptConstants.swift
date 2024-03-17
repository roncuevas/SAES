import Foundation

enum JScriptCode {
    case common
    case getCaptchaImage
    case loginForm(String, String, String)
    case isLogged
    case reloadCaptcha
    case logout
    case personalData
    
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
        }
    }
}

struct JavaScriptConstants {
    static var common: String = """
    function byID(id) {
      return document.getElementById(id);
    }

    function byClass(className) {
      return document.getElementsByClassName(className);
    }

    function byTag(tag) {
      return document.getElementsByTagName(tag);
    }

    function byName(name) {
      return document.getElementsByName(name);
    }

    function bySelector(selector) {
      return document.querySelector(selector);
    }

    function bySelectorAll(selector) {
      return document.querySelectorAll(selector);
    }

    function postMessage(message) {
        window.webkit.messageHandlers.myNativeApp.postMessage(message);
    }

    function imageToData(imageElement) {
        var canvas = document.createElement("canvas");
        var context = canvas.getContext("2d");
        canvas.width = imageElement.width;
        canvas.height = imageElement.height;
        context.drawImage(imageElement, 0, 0);
        var imageData = canvas.toDataURL("image/jpeg");
        return imageData
    }
    """
    
    static var getCaptchaImage = """
    function getCaptchaImage() {
        var captchaImage = byID('c_default_ctl00_leftcolumn_loginuser_logincaptcha_CaptchaImage');
        var dict = {};
        dict["imageData"] = imageToData(captchaImage);
        postMessage(dict);
    }
    getCaptchaImage();
    """
    
    static func loginForm(boleta: String, password: String, captcha: String) -> String {
        return """
        var userElement = byID('ctl00_leftColumn_LoginUser_UserName');
        userElement.value = "\(boleta)"
        var passwordElement = byID('ctl00_leftColumn_LoginUser_Password');
        passwordElement.value = "\(password)"
        var captchaElement = byID('ctl00_leftColumn_LoginUser_CaptchaCodeTextBox');
        captchaElement.value = "\(captcha)"
        var loginButton = byID('ctl00_leftColumn_LoginUser_LoginButton');
        loginButton.click();
        """
    }
    
    static var isLogged = """
    var isLogged = byID('ctl00_leftColumn_LoginUser_LoginButton') ? "0" : "1";
    var dict = {};
    dict['isLogged'] = isLogged;
    postMessage(dict);
    """
    
    static var reloadCaptcha = """
    var reloadCaptcha = byID('c_default_ctl00_leftcolumn_loginuser_logincaptcha_ReloadLink');
    reloadCaptcha.click();
    """
    
    static var logout = """
    var logoutButton = byID('ctl00_leftColumn_LoginStatusSession');
    logoutButton.click();
    """
    
    static var personalData = """
    var name = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Nombre');
    var dict = {};
    dict['name'] = name.value;
    """
}
