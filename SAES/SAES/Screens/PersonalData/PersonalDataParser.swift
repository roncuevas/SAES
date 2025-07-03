import Foundation
import SwiftSoup

struct PersonalDataParser: SAESParser {
    func parse(data: Data) throws -> PersonalDataModel {
        let html = try convert(data)
        if try html.title().contains("IPN-SAES") { throw SAESFetcherError.userLoggedOut }
        return PersonalDataModel(
            name: try selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Nombre").text(),
            studentID: try selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Boleta").text(),
            campus: try selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Plantel").text(),
            curp: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_CURP").text(),
            rfc: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_RFC").text(),
            militaryID: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Cartilla").text(),
            passport: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Pasaporte").text(),
            gender: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Generales_Lbl_Sexo").text(),
            birthday: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_FecNac").text(),
            nationality: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_Nacionalidad").text(),
            birthPlace: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_TabPanel1_Lbl_EntNac").text(),
            street: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Calle").text(),
            extNumber: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_NumExt").text(),
            intNumber: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_NumInt").text(),
            neighborhood: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Colonia").text(),
            zipCode: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_CP").text(),
            state: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Estado").text(),
            municipality: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_DelMpo").text(),
            phone: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Tel").text(),
            mobile: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Movil").text(),
            email: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_eMail").text(),
            working: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_Labora").text(),
            officePhone: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Direccion_Lbl_TelOficina").text(),
            schoolOrigin: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_EscProc").text(),
            schoolOriginLocation: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_EdoEscProc").text(),
            gpaMiddleSchool: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_PromSec").text(),
            gpaHighSchool: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Escolaridad_Lbl_PromNMS").text(),
            guardianName: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_NomTut").text(),
            guardianRFC: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_RFCTut").text(),
            fathersName: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_Padre").text(),
            mothersName: try? selectorVariants(element: html, "#ctl00_mainCopy_TabContainer1_Tab_Tutor_Lbl_Madre").text()
        )
    }
}
