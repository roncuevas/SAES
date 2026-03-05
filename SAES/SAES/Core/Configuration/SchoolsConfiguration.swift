import Foundation

struct SchoolsConfiguration {
    let highSchools: [SchoolEntry]
    let universities: [SchoolEntry]

    struct SchoolEntry {
        let name: String
        let longName: String
        let code: String
        let saesURL: String
        let order: Int
    }

    func toSchoolDataDictionary(_ entries: [SchoolEntry]) -> [SchoolCodes: SchoolData] {
        var dict: [SchoolCodes: SchoolData] = [:]
        for entry in entries {
            guard let code = SchoolCodes(rawValue: entry.code) else { continue }
            dict[code] = SchoolData(name: entry.name, longName: entry.longName, code: code, saes: entry.saesURL, order: entry.order)
        }
        return dict
    }

    // swiftlint:disable function_body_length
    static let shared = SchoolsConfiguration(
        highSchools: [
            SchoolEntry(name: "CET 1", longName: "CET 1 Walter Cross Buchanan", code: "cet1", saesURL: "https://www.saes.cet1.ipn.mx/", order: 0),
            SchoolEntry(name: "CECyT 1", longName: "CECyT 1 Gonzalo Vázquez Vela", code: "cecyt1", saesURL: "https://www.saes.cecyt1.ipn.mx/", order: 1),
            SchoolEntry(name: "CECyT 2", longName: "CECyT 2 Miguel Bernard", code: "cecyt2", saesURL: "https://www.saes.cecyt2.ipn.mx/", order: 2),
            SchoolEntry(name: "CECyT 3", longName: "CECyT 3 Estanislao Ramirez Ruíz", code: "cecyt3", saesURL: "https://www.saes.cecyt3.ipn.mx/", order: 3),
            SchoolEntry(name: "CECyT 4", longName: "CECyT 4 Lázaro Cárdenas", code: "cecyt4", saesURL: "https://www.saes.cecyt4.ipn.mx/", order: 4),
            SchoolEntry(name: "CECyT 5", longName: "CECyT 5 Benito Juárez", code: "cecyt5", saesURL: "https://www.saes.cecyt5.ipn.mx/", order: 5),
            SchoolEntry(name: "CECyT 6", longName: "CECyT 6 Miguel Othón de Mendizábal", code: "cecyt6", saesURL: "https://www.saes.cecyt6.ipn.mx/", order: 6),
            SchoolEntry(name: "CECyT 7", longName: "CECyT 7 Cuauhtémoc", code: "cecyt7", saesURL: "https://www.saes.cecyt7.ipn.mx/", order: 7),
            SchoolEntry(name: "CECyT 8", longName: "CECyT 8 Narciso Bassols", code: "cecyt8", saesURL: "https://www.saes.cecyt8.ipn.mx/", order: 8),
            SchoolEntry(name: "CECyT 9", longName: "CECyT 9 Juan de Dios Bátiz", code: "cecyt9", saesURL: "https://www.saes.cecyt9.ipn.mx/", order: 9),
            SchoolEntry(name: "CECyT 10", longName: "CECyT 10 Carlos Vallejo Márquez", code: "cecyt10", saesURL: "https://www.saes.cecyt10.ipn.mx/", order: 10),
            SchoolEntry(name: "CECyT 11", longName: "CECyT 11 Wilfrido Massieu", code: "cecyt11", saesURL: "https://www.saes.cecyt11.ipn.mx/", order: 11),
            SchoolEntry(name: "CECyT 12", longName: "CECyT 12 José María Morelos", code: "cecyt12", saesURL: "https://www.saes.cecyt12.ipn.mx/", order: 12),
            SchoolEntry(name: "CECyT 13", longName: "CECyT 13 Ricardo Flores Magón", code: "cecyt13", saesURL: "https://www.saes.cecyt13.ipn.mx/", order: 13),
            SchoolEntry(name: "CECyT 14", longName: "CECyT 14 Luis Enrique Erro", code: "cecyt14", saesURL: "https://www.saes.cecyt14.ipn.mx/", order: 14),
            SchoolEntry(name: "CECyT 15", longName: "CECyT 15 Diódoro Antúnez Echegaray", code: "cecyt15", saesURL: "https://www.saes.cecyt15.ipn.mx/", order: 15),
            SchoolEntry(name: "CECyT 16", longName: "CECyT 16 Hidalgo", code: "cecyt16", saesURL: "https://www.saes.cecyt16.ipn.mx/", order: 16),
            SchoolEntry(name: "CECyT 17", longName: "CECyT 17 León, Guanajuato", code: "cecyt17", saesURL: "https://www.saes.cecyt17.ipn.mx/", order: 17),
            SchoolEntry(name: "CECyT 18", longName: "CECyT 18 Zacatecas", code: "cecyt18", saesURL: "https://www.saes.cecyt18.ipn.mx/", order: 18),
            SchoolEntry(name: "CECyT 19", longName: "CECyT 19 Leona Vicario", code: "cecyt19", saesURL: "https://www.saes.cecyt19.ipn.mx/", order: 19)
        ],
        universities: [
            SchoolEntry(name: "CICS Milpa Alta", longName: "Centro Interdisciplinario de Ciencias de la Salud Milpa Alta", code: "cicsma", saesURL: "https://www.saes.cicsma.ipn.mx/", order: 0),
            SchoolEntry(name: "CICS UST", longName: "Centro Interdisciplinario de Ciencias de la Salud Santo Tomás", code: "cicsst", saesURL: "https://www.saes.cicsst.ipn.mx/", order: 0),
            SchoolEntry(name: "ENCB", longName: "Escuela Nacional de Ciencias Biológicas", code: "encb", saesURL: "https://www.saes.encb.ipn.mx/", order: 0),
            SchoolEntry(name: "ENMH", longName: "Escuela Nacional de Medicina y Homeopatía", code: "enmh", saesURL: "https://www.saes.enmh.ipn.mx/", order: 0),
            SchoolEntry(name: "ESCA Santo Tomas", longName: "Escuela Superior de Comercio y Administración Santo Tomás", code: "escasto", saesURL: "https://www.saes.escasto.ipn.mx/", order: 0),
            SchoolEntry(name: "ESCA Tepepan", longName: "Escuela Superior de Comercio y Administración Tepepan", code: "escatep", saesURL: "https://www.saes.escatep.ipn.mx/", order: 0),
            SchoolEntry(name: "ESCOM", longName: "Escuela Superior de Cómputo", code: "escom", saesURL: "https://www.saes.escom.ipn.mx/", order: 0),
            SchoolEntry(name: "ESE", longName: "Escuela Superior de Economía", code: "ese", saesURL: "https://www.saes.ese.ipn.mx/", order: 0),
            SchoolEntry(name: "ESEO", longName: "Escuela Superior de Enfermería y Obstetricia", code: "eseo", saesURL: "https://www.saes.eseo.ipn.mx/", order: 0),
            SchoolEntry(name: "ESFM", longName: "Escuela Superior de Física y Matemáticas", code: "esfm", saesURL: "https://www.saes.esfm.ipn.mx/", order: 0),
            SchoolEntry(name: "ESIA Tecamachalco", longName: "Escuela Superior de Ingeniería y Arquitectura Tecamachalco", code: "esiatec", saesURL: "https://www.saes.esiatec.ipn.mx/", order: 0),
            SchoolEntry(name: "ESIA Ticoman", longName: "Escuela Superior de Ingeniería y Arquitectura Ticomán", code: "esiatic", saesURL: "https://www.saes.esiatic.ipn.mx/", order: 0),
            SchoolEntry(name: "ESIA Zacatenco", longName: "Escuela Superior de Ingeniería y Arquitectura Zacatenco", code: "esiaz", saesURL: "https://www.saes.esiaz.ipn.mx/", order: 0),
            SchoolEntry(name: "ESIME Azcapotzalco", longName: "Escuela Superior de Ingeniería Mecánica y Eléctrica Azcapotzalco", code: "esimeazc", saesURL: "https://www.saes.esimeazc.ipn.mx/", order: 0),
            SchoolEntry(name: "ESIME Culhuacán", longName: "Escuela Superior de Ingeniería Mecánica y Eléctrica Culhuacán", code: "esimecu", saesURL: "https://www.saes.esimecu.ipn.mx/", order: 0),
            SchoolEntry(name: "ESIME Ticomán", longName: "Escuela Superior de Ingeniería Mecánica y Eléctrica Ticomán", code: "esimetic", saesURL: "https://www.saes.esimetic.ipn.mx/", order: 0),
            SchoolEntry(name: "ESIME Zacatenco", longName: "Escuela Superior de Ingeniería Mecánica y Eléctrica Zacatenco", code: "esimez", saesURL: "https://www.saes.esimez.ipn.mx/", order: 0),
            SchoolEntry(name: "ESIQIE", longName: "Escuela Superior de Ingeniería Química e Industrias Extractivas", code: "esiqie", saesURL: "https://www.saes.esiqie.ipn.mx/", order: 0),
            SchoolEntry(name: "ESM", longName: "Escuela Superior de Medicina", code: "esm", saesURL: "https://www.saes.esm.ipn.mx/", order: 0),
            SchoolEntry(name: "ESIT", longName: "Escuela Superior de Ingeniería Textil", code: "esit", saesURL: "https://www.saes.esit.ipn.mx/", order: 0),
            SchoolEntry(name: "EST", longName: "Escuela Superior de Turismo", code: "est", saesURL: "https://www.saes.est.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIBI", longName: "Unidad Profesional Interdisciplinaria de Biotecnología", code: "upibi", saesURL: "https://www.saes.upibi.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIICSA", longName: "Unidad Profesional Interdisciplinaria de Ingeniería y Ciencias Sociales y Administrativas", code: "upiicsa", saesURL: "https://www.saes.upiicsa.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIIG", longName: "Unidad Profesional Interdisciplinaria de Ingeniería Campus Guanajuato", code: "upiig", saesURL: "https://www.saes.upiig.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIITA", longName: "Unidad Profesional Interdisciplinaria en Ingeniería y Tecnologías Avanzadas", code: "upiita", saesURL: "https://www.saes.upiita.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIIZ", longName: "Unidad Profesional Interdisciplinaria de Ingeniería Campus Zacatecas", code: "upiiz", saesURL: "https://www.saes.upiiz.ipn.mx/", order: 0),
            SchoolEntry(name: "ENBA", longName: "Escuela Nacional de Biblioteconomía y Archivonomía", code: "enba", saesURL: "https://www.saes.enba.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIIH", longName: "Unidad Profesional Interdisciplinaria de Ingeniería Campus Hidalgo", code: "upiih", saesURL: "https://www.saes.upiih.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIIP", longName: "Unidad Profesional Interdisciplinaria de Ingeniería Campus Palenque", code: "upiip", saesURL: "https://www.saes.upiip.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIIC", longName: "Unidad Profesional Interdisciplinaria de Ingeniería Campus Coahuila", code: "upiic", saesURL: "https://www.saes.upiic.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIEM", longName: "Unidad Profesional Interdisciplinaria de Energía y Movilidad", code: "upiem", saesURL: "https://www.saes.upiem.ipn.mx/", order: 0),
            SchoolEntry(name: "UPIIT", longName: "Unidad Profesional Interdisciplinaria de Ingeniería Campus Tlaxcala", code: "upiit", saesURL: "https://www.saes.upiit.ipn.mx/", order: 0)
        ]
    )
    // swiftlint:enable function_body_length
}
