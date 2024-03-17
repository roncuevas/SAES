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
        }
    }
}

struct JavaScriptConstants {
    static var common: String = """
    var dict = {};
    var userElement = byID('ctl00_leftColumn_LoginUser_UserName');
    var passwordElement = byID('ctl00_leftColumn_LoginUser_Password');
    var captchaElement = byID('ctl00_leftColumn_LoginUser_CaptchaCodeTextBox');
    var loginButton = byID('ctl00_leftColumn_LoginUser_LoginButton');
    var name = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Nombre').innerText;
    var curp = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_CURP');
    var rfc = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_RFC');
    var birthday = byID('ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_FecNac');
    var nationality = byID('ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_Nacionalidad');
    var birthLocation = byID('ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_EntNac');
    var reloadCaptcha = byID('c_default_ctl00_leftcolumn_loginuser_logincaptcha_ReloadLink');
    var isLogged = byID('ctl00_leftColumn_LoginStatusSession') ? "1" : "0";
    var isErrorPage = document.body.innerHTML.includes("Error de servidor en la aplicación '/'.") ? "1" : "0";
    var logoutButton = byID('ctl00_leftColumn_LoginStatusSession');
    
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
    
    function getCaptchaImage() {
        var captchaImage = byID('c_default_ctl00_leftcolumn_loginuser_logincaptcha_CaptchaImage');
        dict["imageData"] = imageToData(captchaImage);
        postMessage(dict);
    }
    """
    
    static var getCaptchaImage = """
    getCaptchaImage();
    """
    
    static func loginForm(boleta: String, password: String, captcha: String) -> String {
        return """
        userElement.value = "\(boleta)"
        passwordElement.value = "\(password)"
        captchaElement.value = "\(captcha)"
        loginButton.click();
        """
    }
    
    static var isLogged = """
    isLogged = byID('ctl00_leftColumn_LoginStatusSession') ? "1" : "0";
    dict['isLogged'] = isLogged;
    postMessage(dict);
    """
    
    static var reloadCaptcha = """
    reloadCaptcha.click();
    """
    
    static var logout = """
    logoutButton.click();
    """
    
    static var personalData = """
    dict['name'] = name;
    dict['curp'] = curp.innerText;
    dict['rfc'] = rfc.innerText;
    postMessage(dict);
    """
    
    static var isErrorPage = """
    dict['isErrorPage'] = isErrorPage;
    postMessage(dict);
    """
}
