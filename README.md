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
- ✅ **Horario semanal** de clases
- ✅ **Kardex completo** con promedios por semestre
- ✅ **Datos personales** con foto del estudiante

### 🪪 Credencial digital
- ✅ **Escaneo de código QR** de la credencial del IPN
- ✅ **Generación de credencial digital** dentro de la app
- ✅ **Exportación como imagen** para compartir o guardar

### 📝 Evaluación docente
- ✅ **Evaluación automática** de maestros desde la app

### 🏛 Herramientas IPN
- ✅ **Noticias IPN** — feed de noticias actualizado
- ✅ **Calendario académico IPN** — importación vía iCal
- ✅ **Consulta de disponibilidad de horarios** por unidad académica

### 📅 Horario
- ✅ **Exportar comprobante** de inscripción en PDF
- ✅ **Agregar clases al calendario** del dispositivo

### 🔒 Seguridad
- ✅ **Cifrado ChaCha20** para credenciales almacenadas
- ✅ **Sesiones por cookies** — sin tokens almacenados externamente
- ✅ **Sin almacenamiento externo** — los datos no se comparten con terceros

### 🎨 Experiencia
- ✅ **Modo oscuro** — sistema, claro u oscuro
- ✅ **Localización** — español e inglés
- ✅ **Haptic feedback** configurable
- ✅ **Tab por defecto** personalizable

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
