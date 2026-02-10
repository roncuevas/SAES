/**
 * evaluate_teacher.js
 * Automatiza la evaluacion docente en el portal SAES.
 *
 * Selecciona la calificacion mas alta en todos los campos,
 * marca todos los checkboxes y hace click en el boton de aceptar.
 */
(() => {
  // Selecciona la última opción de cada <select>
  document.querySelectorAll('select').forEach(select => {
    select.selectedIndex = select.options.length - 1;
  });

  // Marca todos los checkboxes y dispara el evento change
  document.querySelectorAll('input[type="checkbox"]').forEach(cb => {
    cb.checked = true;
    cb.dispatchEvent(new Event('change', { bubbles: true }));
  });

  // Para este botón, busca primero "mainCopy_Aceptar", si no existe prueba con "ctl00_mainCopy_Aceptar"
  const btn =
    document.getElementById('mainCopy_Aceptar') ||
    document.getElementById('ctl00_mainCopy_Aceptar');

  if (btn) btn.click();
})();
