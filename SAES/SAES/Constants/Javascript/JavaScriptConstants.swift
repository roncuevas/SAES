import Foundation

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
        userElement.value = "\(boleta)";
        passwordElement.value = "\(password)";
        captchaElement.value = "\(captcha)";
        loginButton.click();
        """
    }
    
    static var reloadCaptcha = """
    var reloadCaptcha = byID('c_default_ctl00_leftcolumn_loginuser_logincaptcha_ReloadLink');
    reloadCaptcha.click();
    """
    
    @available(*, deprecated, renamed: "logout")
    static var logoutDeprecated = """
    __doPostBack('ctl00$leftColumn$LoginStatusSession$ctl00', '');
    """
    
    static var logout = """
    var logoutButton = byID('ctl00_leftColumn_LoginStatusSession');
    logoutButton.click();
    """
    
    static var personalData = """
    dict['studentID'] = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Boleta').innerText;
    dict['name'] = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Nombre').innerText;
    dict['campus'] = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Plantel').innerText;
    dict['curp'] = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_CURP').innerText;
    dict['rfc'] = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_RFC').innerText;
    dict['militaryID'] = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Cartilla').innerText;
    dict['passport'] = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Pasaporte').innerText;
    dict['gender'] = byID('ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Sexo').innerText;
    dict['birthday'] = byID('ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_FecNac').innerText;
    dict['nationality'] = byID('ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_Nacionalidad').innerText;
    dict['birthPlace'] = byID('ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_EntNac').innerText;
    dict['street'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Calle').innerText;
    dict['extNumber'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_NumExt').innerText;
    dict['intNumber'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_NumInt').innerText;
    dict['neighborhood'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Colonia').innerText;
    dict['zipCode'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_CP').innerText;
    dict['state'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Estado').innerText;
    dict['municipality'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_DelMpo').innerText;
    dict['phone'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Tel').innerText;
    dict['mobile'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Movil').innerText;
    dict['email'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_eMail').innerText;
    dict['working'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Labora').innerText;
    dict['officePhone'] = byID('ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_TelOficina').innerText;
    dict['schoolOrigin'] = byID('ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_EscProc').innerText;
    dict['schoolOriginLocation'] = byID('ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_EdoEscProc').innerText;
    dict['gpaMiddleSchool'] = byID('ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_PromSec').innerText;
    dict['gpaHighSchool'] = byID('ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_PromNMS').innerText;
    dict['guardianName'] = byID('ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_NomTut').innerText;
    dict['guardianRFC'] = byID('ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_RFCTut').innerText;
    dict['fathersName'] = byID('ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_Padre').innerText;
    dict['mothersName'] = byID('ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_Madre').innerText;
    postMessage(dict);
    """
    
    static var isErrorPage = """
    var isErrorPage = document.body.innerHTML.includes("Error de servidor en la aplicación '/'.") ? "1" : "0";
    var errorText = document.querySelector("span.failureNotification:not([style*='visibility:hidden']):not([style*='display:none']):not([style*='opacity:0'])").textContent.trimStart().trimEnd();
    var isErrorCaptcha = errorText.length > 0 ? "1" : "0";
    dict['errorText'] = errorText;
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
    
    static var kardex = """
    function getKardexJSON() {
        const doc = byID("ctl00_mainCopy_Panel1");
        const carrera = doc.querySelector("#ctl00_mainCopy_Lbl_Carrera").textContent.trim();
        const plan = doc.querySelector("#ctl00_mainCopy_Lbl_Plan").textContent.trim();
        const promedio = doc.querySelector("#ctl00_mainCopy_Lbl_Promedio").textContent.trim().replace(',', '.');

        const kardexTable = doc.querySelectorAll("#ctl00_mainCopy_Lbl_Kardex center table");

        let kardex = [];

        kardexTable.forEach((table, semesterIndex) => {
            const semesterName = table.querySelector("tr:first-child td").textContent.trim();
            const rows = table.querySelectorAll("tr:not(:first-child):not(:nth-child(2))");

            let materias = [];
            rows.forEach(row => {
                const columns = row.querySelectorAll("td");
                if (columns.length > 0) {
                    const materia = {
                        clave: columns[0].textContent.trim(),
                        materia: columns[1].textContent.trim(),
                        fecha: columns[2].textContent.trim(),
                        periodo: columns[3].textContent.trim(),
                        forma_eval: columns[4].textContent.trim(),
                        calificacion: columns[5].textContent.trim()
                    };
                    materias.push(materia);
                }
            });

            kardex.push({
                semestre: semesterName,
                materias: materias
            });
        });

        const jsonResult = {
            carrera: carrera,
            plan: plan,
            promedio: promedio,
            kardex: kardex
        };

        return JSON.stringify(jsonResult, null, 2);
    }
    dict['kardex'] = getKardexJSON();
    postMessage(dict);
    """
    
    static var kardexAI = """
    dict['kardex'] = byID("ctl00_mainCopy_Panel1").outerText;
    postMessage(dict);
    """
    
    static func ocupabilidad() -> String {
        """
        document.querySelector('[id="ctl00_mainCopy_rblEsquema_1"]').checked = true;
        __doPostBack('ctl00$mainCopy$rblEsquema$0','');
        """
    }
}
