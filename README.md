# 📱 SAES para iOS

Aplicación no oficial del **Sistema de Administración Escolar (SAES)** para estudiantes del **Instituto Politécnico Nacional (IPN)**. Consulta calificaciones, horarios, Kardex, credencial digital y más desde una interfaz nativa en SwiftUI.

![iOS 16+](https://img.shields.io/badge/iOS-16.0%2B-blue)
![Swift 5](https://img.shields.io/badge/Swift-5-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-purple)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

⚠️ **Aviso importante:** Esta aplicación **no está afiliada, patrocinada ni respaldada por el IPN**. Es un proyecto desarrollado por un estudiante del IPN con el objetivo de mejorar la experiencia de los usuarios del SAES.

---

## 📌 Funcionalidades

### 📚 Consulta académica
- ✅ **Calificaciones** — parciales, final y ETS
- ✅ **Horario semanal** — vista en lista y cuadrícula con colores por materia
- ✅ **Kardex completo** con promedios por semestre
- ✅ **Datos personales** con foto del estudiante
- ✅ **Evaluación docente** — evaluación automática desde la app

### 🪪 Credencial digital
- ✅ **Escaneo de código QR** de la credencial del IPN
- ✅ **Generación de credencial digital** con QR y código de barras
- ✅ **Exportación como imagen** para compartir o guardar
- ✅ **Detección de escuela** — alerta si el QR es de otra escuela

### 🏠 Pantalla de inicio
- ✅ **Próximos eventos** del calendario IPN
- ✅ **Noticias IPN** — feed con vista de cuadrícula y lista
- ✅ **Horario del día** — clases programadas para hoy o el siguiente día
- ✅ **Anuncios** — anuncios importantes del IPN
- ✅ **Becas** — convocatorias disponibles ordenadas por prioridad
- ✅ **Secciones configurables** — mostrar/ocultar cada sección

### 📢 Anuncios y becas
- ✅ **Búsqueda de anuncios** por título y descripción
- ✅ **Filtros** — por tipo (urgente/normal), escuela, expiración
- ✅ **Becas** — listado con búsqueda y vista de detalle

### 🏛 Herramientas IPN
- ✅ **Noticias IPN** — feed con búsqueda y modos de vista
- ✅ **Calendario académico IPN** — importación vía iCal (presencial y en línea)
- ✅ **Consulta de disponibilidad de horarios** por unidad académica

### 📅 Horario y calendario
- ✅ **Exportar comprobante** de inscripción en PDF
- ✅ **Agregar clases al calendario** del dispositivo con alarmas configurables
- ✅ **Eliminar clases del calendario** previamente exportadas
- ✅ **Detalle de clase** — salón, maestro y edificio en modal

### 📴 Modo sin conexión
- ✅ **Datos offline** — calificaciones, kardex, horario y datos personales en caché
- ✅ **Última actualización** — muestra cuándo se guardaron los datos
- ✅ **Exportación desde offline** — exportar calendario y comprobante sin conexión

### 📲 Widgets
- ✅ **Widget de horario** — clases del día en pantalla de inicio/bloqueo
- ✅ **Widget de eventos IPN** — próximos eventos del calendario
- ✅ **Selector de escuela** — elegir qué escuela mostrar en el widget

### 🔗 Deep links y notificaciones
- ✅ **Deep links** — esquema `saes://` para navegar a tabs y pantallas
- ✅ **Notificaciones push** — integración con Firebase Cloud Messaging
- ✅ **Deep links desde notificaciones** — navegación directa desde push

### 🔒 Seguridad y privacidad
- ✅ **Cifrado ChaCha20** para credenciales almacenadas
- ✅ **Sesiones por cookies** — sin tokens almacenados externamente
- ✅ **Sin almacenamiento externo** — los datos no se comparten con terceros
- ✅ **Modo captura de pantalla** — redacta datos sensibles automáticamente
- ✅ **Campos privados** — credencial, kardex, calificaciones y login marcados como sensibles

### 🎨 Experiencia
- ✅ **Modo oscuro** — sistema, claro u oscuro
- ✅ **Localización** — español (México) e inglés
- ✅ **Haptic feedback** configurable
- ✅ **Tab por defecto** personalizable
- ✅ **Toasts** — notificaciones contextuales de éxito/error
- ✅ **Animaciones Lottie** — indicadores de carga animados

### 🛠 Herramientas de depuración
- ✅ **Modo debug** — habilitado automáticamente en builds de desarrollo
- ✅ **Feature flags** — visualización de flags de Remote Config
- ✅ **Override de API** — cambiar URL base para pruebas
- ✅ **Copiar tokens** — FCM y autenticación
- ✅ **Limpiar cookies** — borrar sesión manualmente
- ✅ **Vista previa** de mantenimiento y actualización forzada

---

## 📸 Capturas de pantalla

<!-- Agregar capturas de pantalla aquí -->

---

## 📋 Requisitos

| Requisito | Versión |
|-----------|---------|
| iOS | 16.0+ |
| Xcode | 16+ |
| Swift | 5 |
| Dependencias | Swift Package Manager |

---

## 🔧 Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/roncuevas/SAES.git
   cd SAES
   ```
2. **Abrir** el proyecto en Xcode.
3. **Compilar y ejecutar** en un simulador o dispositivo iOS.

> 💡 Las dependencias de Swift Package Manager se resuelven automáticamente al abrir el proyecto.

---

## 🏗 Arquitectura

El proyecto sigue el patrón **MVVM + Web Scraping** con dos flujos de datos:

| Capa | Responsabilidad |
|------|-----------------|
| **View** | Interfaz SwiftUI, bindea al ViewModel |
| **ViewModel** | `ObservableObject` con estado `@Published` |
| **DataSource** | Obtiene HTML mediante URLSession |
| **Parser** | Convierte HTML a modelos con SwiftSoup |

Para formularios complejos (como evaluación docente) se utiliza un **puente JavaScript ↔ Swift** mediante WKWebView.

---

## 📦 Dependencias principales

| Dependencia | Uso |
|-------------|-----|
| [SwiftSoup](https://github.com/scinfu/SwiftSoup) | Parsing de HTML |
| [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) | Cifrado ChaCha20 de credenciales |
| [Kingfisher](https://github.com/onevcat/Kingfisher) | Carga y caché de imágenes |
| [Lottie](https://github.com/airbnb/lottie-spm) | Animaciones |
| Firebase | Analytics, Crashlytics, Messaging, Remote Config |

---

## 🔗 Links útiles

- 🍎 [App Store](https://apps.apple.com/app/id6467482580?action=write-review)
- ✈️ [TestFlight (beta)](https://testflight.apple.com/join/chRbe5EF)
- 💬 [Formulario de feedback](https://forms.gle/9GP2Mc74urEP54vz9)

---

## ⚠️ Descargo de responsabilidad

- ❌ Esta aplicación es un **proyecto independiente** y no tiene ninguna relación con el Instituto Politécnico Nacional (IPN).
- 🔒 Las credenciales se **cifran localmente** y no son almacenadas ni compartidas con terceros.
- ⚠️ El uso de esta aplicación es **bajo la responsabilidad del usuario**.

---

## 📬 Contacto

Si tienes alguna sugerencia o problema, puedes abrir un [issue](https://github.com/roncuevas/SAES/issues) en este repositorio o contactar al desarrollador:

- 👨‍💻 **Desarrollador:** roncuevas
- 📧 **Email:** contacto@roncuevas.com

¡Cualquier contribución es bienvenida! 🎉
