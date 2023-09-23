import Foundation

struct HighSchoolConstants {
    static var schools: [SchoolCodes: SchoolData] = [
        .cet1: SchoolData(name: "CET 1 Walter Cross Buchanan", code: .cet1, saes: "https://www.saes.cet1.ipn.mx/", order: 0),
        .cecyt1: SchoolData(name: "CECyT 1 Gonzalo Vázquez Vela", code: .cecyt1, saes: "https://www.saes.cecyt1.ipn.mx/", order: 1),
        .cecyt2: SchoolData(name: "CECyT 2 Miguel Bernard", code: .cecyt2, saes: "https://www.saes.cecyt2.ipn.mx/", order: 2),
        .cecyt3: SchoolData(name: "CECyT 3 Estanislao Ramirez Ruíz", code: .cecyt3, saes: "https://www.saes.cecyt3.ipn.mx/", order: 3),
        .cecyt4: SchoolData(name: "CECyT 4 Lázaro Cárdenas", code: .cecyt4, saes: "https://www.saes.cecyt4.ipn.mx/", order: 4),
        .cecyt5: SchoolData(name: "CECyT 5 Benito Juárez", code: .cecyt5, saes: "https://www.saes.cecyt5.ipn.mx/", order: 5),
        .cecyt6: SchoolData(name: "CECyT 6 Miguel Othón de Mendizábal", code: .cecyt6, saes: "https://www.saes.cecyt6.ipn.mx/", order: 6),
        .cecyt7: SchoolData(name: "CECyT 7 Cuauhtémoc", code: .cecyt7, saes: "https://www.saes.cecyt7.ipn.mx/", order: 7),
        .cecyt8: SchoolData(name: "CECyT 8 Narciso Bassols", code: .cecyt8, saes: "https://www.saes.cecyt8.ipn.mx/", order: 8),
        .cecyt9: SchoolData(name: "CECyT 9 Juan de Dios Bátiz", code: .cecyt9, saes: "https://www.saes.cecyt9.ipn.mx/", order: 9),
        .cecyt10: SchoolData(name: "CECyT 10 Carlos Vallejo Márquez", code: .cecyt10, saes: "https://www.saes.cecyt10.ipn.mx/", order: 10),
        .cecyt11: SchoolData(name: "CECyT 11 Wilfrido Massieu", code: .cecyt11, saes: "https://www.saes.cecyt11.ipn.mx/", order: 11),
        .cecyt12: SchoolData(name: "CECyT 12 José María Morelos", code: .cecyt12, saes: "https://www.saes.cecyt12.ipn.mx/", order: 12),
        .cecyt13: SchoolData(name: "CECyT 13 Ricardo Flores Magón", code: .cecyt13, saes: "https://www.saes.cecyt13.ipn.mx/", order: 13),
        .cecyt14: SchoolData(name: "CECyT 14 Luis Enrique Erro", code: .cecyt14, saes: "https://www.saes.cecyt14.ipn.mx/", order: 14),
        .cecyt15: SchoolData(name: "CECyT 15 Diódoro Antúnez Echegaray", code: .cecyt15, saes: "https://www.saes.cecyt15.ipn.mx/", order: 15),
        .cecyt16: SchoolData(name: "CECyT 16 Hidalgo", code: .cecyt16, saes: "https://www.saes.cecyt16.ipn.mx/", order: 16),
        .cecyt17: SchoolData(name: "CECyT 17 León, Guanajuato", code: .cecyt17, saes: "https://www.saes.cecyt17.ipn.mx/", order: 17),
        .cecyt18: SchoolData(name: "CECyT 18 Zacatecas", code: .cecyt18, saes: "https://www.saes.cecyt18.ipn.mx/", order: 18),
        .cecyt19: SchoolData(name: "CECyT 19 Leona Vicario", code: .cecyt19, saes: "https://www.saes.cecyt19.ipn.mx/", order: 19)
    ]
    
    static var allSchoolsData: [SchoolData] {
        Array(schools.values)
    }
}
