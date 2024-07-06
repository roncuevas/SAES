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
        }
    }
}

struct JavaScriptConstants {
    static var common: String = """
    var dict = {};
    
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

    function imageToData(imageElement, scale) {
        var canvas = document.createElement("canvas");
        var context = canvas.getContext("2d");
        canvas.width = imageElement.width*scale;
        canvas.height = imageElement.height*scale;
        context.drawImage(imageElement, 0, 0);
        var imageData = canvas.toDataURL("image/jpeg");
        return imageData;
    }
    
    function getCaptchaImage() {
        var captchaImage = byID('c_default_ctl00_leftcolumn_loginuser_logincaptcha_CaptchaImage');
        dict["imageData"] = imageToData(captchaImage, 1);
        postMessage(dict);
    }
    
    function getProfileImage() {
        var profileImage = byID('ctl00_mainCopy_Foto');
        dict["profileImageData"] = imageToData(profileImage, 1.5);
        postMessage(dict);
    }
    """
    
    static var getCaptchaImage = """
    getCaptchaImage();
    """
    
    static var getProfileImage = """
    getProfileImage();
    """
    
    static func loginForm(boleta: String, password: String, captcha: String) -> String {
        return """
        var passwordElement = byID('ctl00_leftColumn_LoginUser_Password');
        var captchaElement = byID('ctl00_leftColumn_LoginUser_CaptchaCodeTextBox');
        var loginButton = byID('ctl00_leftColumn_LoginUser_LoginButton');
        var userElement = byID('ctl00_leftColumn_LoginUser_UserName');
        userElement.value = "\(boleta)"
        passwordElement.value = "\(password)"
        captchaElement.value = "\(captcha)"
        loginButton.click();
        """
    }
    
    static var isLogged = """
    var isLogged = byID('ctl00_leftColumn_LoginStatusSession') ? "1" : "0";
    isLogged = byID('ctl00_leftColumn_LoginStatusSession') ? "1" : "0";
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
    var name = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Nombre').innerText;
    var curp = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_CURP');
    var rfc = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_RFC');
    var birthday = byID('ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_FecNac');
    var nationality = byID('ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_Nacionalidad');
    var birthLocation = byID('ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_EntNac');
    dict['name'] = name;
    dict['curp'] = curp.innerText;
    dict['rfc'] = rfc.innerText;
    dict['birthday'] = birthday.innerText;
    dict['nationality'] = nationality.innerText;
    dict['birthLocation'] = birthLocation.innerText;
    postMessage(dict);
    """
    
    static var isErrorPage = """
    var isErrorPage = document.body.innerHTML.includes("Error de servidor en la aplicación '/'.") ? "1" : "0";
    var isErrorCaptcha = document.body.innerHTML.includes("CAPTCHA Incorrecto, intente nuevamente") ? "1" : "0";
    dict['isErrorPage'] = isErrorPage;
    dict['isErrorCaptcha'] = isErrorCaptcha;
    postMessage(dict);
    """
    
    static var schedule = """
    function extraerDatosTablaComoString() {
        var tabla = document.getElementById('ctl00_mainCopy_GV_Horario');
        var filas = tabla.querySelectorAll('tr');
        var encabezados = [];
        var datos = [];

        filas[0].querySelectorAll('th').forEach(function(th) {
            var encabezadoTexto = th.innerText.toLowerCase().replace(/\\n/g, ' ').replace(/ /g, '_');
            if (encabezadoTexto === "miércoles") encabezadoTexto = "miercoles"; // Corregir el acento
            encabezados.push(encabezadoTexto);
        });

        for (var i = 1; i < filas.length; i++) {
            var celdas = filas[i].querySelectorAll('td');
            var filaDatos = {};
            celdas.forEach(function(td, j) {
                var valor = td.innerText.trim();
                // Procesa los rangos de horas para días específicos
                if (['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado'].includes(encabezados[j])) {
                    // Obtiene las horas y los rangos como un objeto
                    let resultado = valor;
                    valor = resultado;
                }
                filaDatos[encabezados[j]] = valor;
            });
            datos.push(filaDatos);
        }

        return JSON.stringify(datos);
    }
    dict['schedule'] = extraerDatosTablaComoString();
    postMessage(dict);
    """
    
    static var grades = """
    function extraerCalificaciones() {
        var tabla = byID('ctl00_mainCopy_GV_Calif');
        var filas = tabla.querySelectorAll('tr');
        var encabezados = [];
        var calificaciones = [];

        // Obtener encabezados de la tabla
        filas[0].querySelectorAll('th').forEach(function(th) {
            var encabezadoTexto = th.innerText.toLowerCase().replace(/\\n/g, ' ').replace(/ /g, '_').replace(/\\./g, '');
            encabezados.push(encabezadoTexto);
        });

        // Obtener los datos de las filas
        for (var i = 1; i < filas.length; i++) {
            var celdas = filas[i].querySelectorAll('td');
            var filaCalificaciones = {};
            celdas.forEach(function(td, j) {
                var valor = td.innerText.trim();
                filaCalificaciones[encabezados[j]] = valor;
            });
            calificaciones.push(filaCalificaciones);
        }

        return JSON.stringify(calificaciones);
    }
    dict['grades'] = extraerCalificaciones();
    postMessage(dict);
    """
}
