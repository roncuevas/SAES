// saes.js – utilidades para automatizar SAES/IPN
(() => {
  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  const q   = (sel, ctx = document) => ctx.querySelector(sel);
  const qa  = (sel, ctx = document) => Array.from(ctx.querySelectorAll(sel));
  const byID    = id        => document.getElementById(id);
  const byClass = className => document.getElementsByClassName(className);

  /** Convierte una <img> a dataURL con el factor de escala indicado. */
  const imageToData = (img, scale = 1) => {
    if (!img) return null;
    const canvas = document.createElement('canvas');
    canvas.width  = img.naturalWidth  * scale;
    canvas.height = img.naturalHeight * scale;
    canvas.getContext('2d').drawImage(img, 0, 0, canvas.width, canvas.height);
    return canvas.toDataURL('image/png', 1);
  };

  // -------------------------------------------------------------------------
  // Funciones de automatización
  // -------------------------------------------------------------------------

  /** Captura la imagen del captcha. */
  function getCaptchaImage() {
    const dict = {};
    let img = byID('c_default_ctl00_leftcolumn_loginuser_logincaptcha_CaptchaImage')
           || byClass('LBD_CaptchaImage')[0];

    if (img) {
      dict.imageData = imageToData(img, 1);
      postMessage(dict);
    } else {
      console.warn('No se encontró la imagen del captcha.');
    }
  }

  /** Recarga el captcha. */
  const reloadCaptcha = () =>
    byID('c_default_ctl00_leftcolumn_loginuser_logincaptcha_ReloadLink')?.click();

  /**
   * Rellena y envía el formulario de login.
   * @param {string} boleta
   * @param {string} password
   * @param {string} captcha
   */
  function fillLoginForm(boleta, password, captcha) {
    const user     = byID('ctl00_leftColumn_LoginUser_UserName');
    const pass     = byID('ctl00_leftColumn_LoginUser_Password');
    const captchaE = byID('ctl00_leftColumn_LoginUser_CaptchaCodeTextBox');
    const btn      = byID('ctl00_leftColumn_LoginUser_LoginButton');

    if (user && pass && captchaE && btn) {
      user.value = boleta;
      pass.value = password;
      captchaE.value = captcha;
      btn.click();
    } else {
      console.warn('No se encontraron los elementos del login.');
    }
  }

  /** Foto de perfil. */
  function getProfileImage() {
    postMessage({
      profileImageData: imageToData(byID('ctl00_mainCopy_Foto'), 1.5)
    });
  }

  /** Datos personales. */
  function extractPersonalData() {
    const $ = sel => q(sel)?.innerText;
    postMessage({
      studentID:      $('#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Boleta'),
      name:           $('#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Nombre'),
      campus:         $('#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Plantel'),
      curp:           $('#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_CURP'),
      rfc:            $('#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_RFC'),
      militaryID:     $('#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Cartilla'),
      passport:       $('#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Pasaporte'),
      gender:         $('#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Sexo'),
      birthday:       $('#ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_FecNac'),
      nationality:    $('#ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_Nacionalidad'),
      birthPlace:     $('#ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_EntNac'),
      street:         $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Calle'),
      extNumber:      $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_NumExt'),
      intNumber:      $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_NumInt'),
      neighborhood:   $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Colonia'),
      zipCode:        $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_CP'),
      state:          $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Estado'),
      municipality:   $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_DelMpo'),
      phone:          $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Tel'),
      mobile:         $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Movil'),
      email:          $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_eMail'),
      working:        $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Labora'),
      officePhone:    $('#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_TelOficina'),
      schoolOrigin:   $('#ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_EscProc'),
      schoolOriginLocation: $('#ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_EdoEscProc'),
      gpaMiddleSchool: $('#ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_PromSec'),
      gpaHighSchool:   $('#ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_PromNMS'),
      guardianName:    $('#ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_NomTut'),
      guardianRFC:     $('#ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_RFCTut'),
      fathersName:     $('#ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_Padre'),
      mothersName:     $('#ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_Madre')
    });
  }

  /** Errores en la página. */
  function checkErrorPage() {
    const html = document.body.innerHTML;
    const errorSpan = q(
      "span.failureNotification:not([style*='visibility:hidden']):not([style*='display:none']):not([style*='opacity:0'])"
    );
    const errorText = errorSpan?.textContent.trim() ?? '';

    postMessage({
      isErrorPage:   html.includes("Error de servidor en la aplicación '/'."),
      errorText,
      isErrorCaptcha: errorText.length > 0
    });
  }

  /** Horario. */
  function extractSchedule() {
    const tabla = byID('ctl00_mainCopy_GV_Horario');
    if (!tabla) return;

    const filas   = qa('tr', tabla);
    const headers = qa('th', filas[0]).map(th =>
      th.innerText.toLowerCase().replace(/\n/g, ' ')
        .replace(/ /g, '_').replace('miércoles', 'miercoles')
    );

    const datos = filas.slice(1).map(tr => {
      const fila = {};
      qa('td', tr).forEach((td, i) => fila[headers[i]] = td.innerText.trim());
      return fila;
    });

    postMessage({ schedule: JSON.stringify(datos) });
  }

  /** Calificaciones. */
  function extractGrades() {
    const tabla = byID('ctl00_mainCopy_GV_Calif');
    if (!tabla) return;

    const filas   = qa('tr', tabla);
    const headers = qa('th', filas[0]).map(th =>
      th.innerText.toLowerCase().replace(/\n/g, ' ')
        .replace(/ /g, '_').replace(/\./g, '')
    );

    const calif = filas.slice(1).map(tr => {
      const fila = {};
      qa('td', tr).forEach((td, i) => fila[headers[i]] = td.innerText.trim());
      return fila;
    });

    postMessage({ grades: JSON.stringify(calif) });
  }

  /** Kardex. */
  function extractKardex() {
    const panel = byID('ctl00_mainCopy_Panel1');
    if (!panel) return;

    const carrera   = q('#ctl00_mainCopy_Lbl_Carrera', panel)?.innerText.trim();
    const plan      = q('#ctl00_mainCopy_Lbl_Plan', panel)?.innerText.trim();
    const promedio  = q('#ctl00_mainCopy_Lbl_Promedio', panel)
                        ?.innerText.trim().replace(',', '.');

    const tables = qa('#ctl00_mainCopy_Lbl_Kardex center table', panel);
    const kardex = tables.map(table => {
      const semestre = q('tr:first-child td', table).innerText.trim();
      const rows     = qa('tr:not(:first-child):not(:nth-child(2))', table);

      const materias = rows.map(row => {
        const [clave, materia, fecha, periodo, forma_eval, calificacion] =
              qa('td', row).map(td => td.innerText.trim());
        return { clave, materia, fecha, periodo, forma_eval, calificacion };
      });

      return { semestre, materias };
    });

    postMessage({
      kardex: JSON.stringify({ carrera, plan, promedio, kardex }, null, 2)
    });
  }

  // -------------------------------------------------------------------------
  // API pública
  // -------------------------------------------------------------------------
  window.SAES = {
    getCaptchaImage,
    reloadCaptcha,
    fillLoginForm,
    getProfileImage,
    extractPersonalData,
    checkErrorPage,
    extractSchedule,
    extractGrades,
    extractKardex
  };
})();
