import Foundation

struct UniversityConstants {
    static var schools: [SchoolCodes: SchoolData] = [
        .cicsma: SchoolData(name: "CICS Milpa Alta", code: .cicsma, saes: "https://www.saes.cicsma.ipn.mx/"),
        .cicsst: SchoolData(name: "CICS UST", code: .cicsst, saes: "https://www.saes.cicsst.ipn.mx/"),
        .encb: SchoolData(name: "ENCB", code: .encb, saes: "https://www.saes.encb.ipn.mx/"),
        .enmh: SchoolData(name: "ENMH", code: .enmh, saes: "https://www.saes.enmh.ipn.mx"),
        .escasto: SchoolData(name: "ESCA Santo Tomas", code: .escasto, saes: "https://www.saes.escasto.ipn.mx/"),
        .escatep: SchoolData(name: "ESCA Tepepan", code: .escatep, saes: "https://www.saes.escatep.ipn.mx/"),
        .escom: SchoolData(name: "ESCOM", code: .escom, saes: "https://www.saes.escom.ipn.mx/"),
        .ese: SchoolData(name: "ESE", code: .ese, saes: "https://www.saes.ese.ipn.mx/"),
        .eseo: SchoolData(name: "ESEO", code: .eseo, saes: "https://www.saes.eseo.ipn.mx/"),
        .esfm: SchoolData(name: "ESFM", code: .esfm, saes: "https://www.saes.esfm.ipn.mx/"),
        .esiatec: SchoolData(name: "ESIA Tecamachalco", code: .esiatec, saes: "https://www.saes.esiatec.ipn.mx/"),
        .esiatic: SchoolData(name: "ESIA Ticoman", code: .esiatic, saes: "https://www.saes.esiatic.ipn.mx/"),
        .esiaz: SchoolData(name: "ESIA-ZAC", code: .esiaz, saes: "https://www.saes.esiaz.ipn.mx/"),
        .esimeazc: SchoolData(name: "ESIME AZCAPOTZALCO", code: .esimeazc, saes: "https://www.saes.esimeazc.ipn.mx/"),
        .esimecu: SchoolData(name: "ESIME CULHUACAN", code: .esimecu, saes: "https://www.saes.esimecu.ipn.mx/"),
        .esimetic: SchoolData(name: "ESIME TICOMAN", code: .esimetic, saes: "https://www.saes.esimetic.ipn.mx/"),
        .esimez: SchoolData(name: "ESIME ZACATENCO", code: .esimez, saes: "https://www.saes.esimez.ipn.mx/"),
        .esiqie: SchoolData(name: "ESIQUIE", code: .esiqie, saes: "https://www.saes.esiqie.ipn.mx/"),
        .esm: SchoolData(name: "ESM", code: .esm, saes: "https://www.saes.esm.ipn.mx/"),
        .esit: SchoolData(name: "ESIT", code: .esit, saes: "https://www.saes.esit.ipn.mx/"),
        .est: SchoolData(name: "EST", code: .est, saes: "https://www.saes.est.ipn.mx/"),
        .upibi: SchoolData(name: "UPIBI", code: .upibi, saes: "https://www.saes.upibi.ipn.mx/"),
        .upiicsa: SchoolData(name: "UPIICSA", code: .upiicsa, saes: "https://www.saes.upiicsa.ipn.mx/"),
        .upiig: SchoolData(name: "UPIIG", code: .upiig, saes: "https://www.saes.upiig.ipn.mx/"),
        .upiita: SchoolData(name: "UPIITA", code: .upiita, saes: "https://www.saes.upiita.ipn.mx/"),
        .upiiz: SchoolData(name: "UPIIZ", code: .upiiz, saes: "https://www.saes.upiiz.ipn.mx/"),
        .enba: SchoolData(name: "ENBA", code: .enba, saes: "https://www.saes.enba.ipn.mx/"),
        .upiih: SchoolData(name: "UPIIH", code: .upiih, saes: "https://www.saes.upiih.ipn.mx/"),
        .upiip: SchoolData(name: "UPIIP", code: .upiip, saes: "https://www.saes.upiip.ipn.mx/"),
        .upiic: SchoolData(name: "UPIIC", code: .upiic, saes: "https://www.saes.upiic.ipn.mx/"),
        .upiem: SchoolData(name: "UPIEM", code: .upiem, saes: "https://www.saes.upiem.ipn.mx/"),
        .upiit: SchoolData(name: "UPIIT", code: .upiit, saes: "https://www.saes.upiit.ipn.mx/")
    ]
    
    static var allSchoolsData: [SchoolData] {
        Array(schools.values)
    }
}
