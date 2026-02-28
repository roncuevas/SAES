import Foundation
import SwiftUI

struct IPNScholarshipResponse: Codable, Sendable {
    let success: Bool
    let data: IPNScholarshipData
}

struct IPNScholarshipData: Codable, Sendable {
    let total: Int
    let nuevas: Int
    let becas: [IPNScholarship]
}

struct IPNScholarship: Codable, Identifiable, Sendable {
    let id: String
    let titulo: String
    let descripcion: String
    let status: IPNScholarshipStatus
    let fecha: String?
    let fechaLabel: String
    let monto: String
    let periodicidad: IPNScholarshipPeriodicidad?
    let tipoBeneficio: IPNScholarshipBeneficio
    let url: String?
    let convocatoriaUrl: String?
    let montoMin: Double?
    let montoMax: Double?

    enum CodingKeys: String, CodingKey {
        case id, titulo, descripcion, status, fecha, monto, periodicidad, url
        case fechaLabel = "fecha_label"
        case tipoBeneficio = "tipo_beneficio"
        case convocatoriaUrl = "convocatoria_url"
        case montoMin = "monto_min"
        case montoMax = "monto_max"
    }
}

enum IPNScholarshipStatus: String, Codable, Sendable {
    case abierta
    case registroAbierto = "registro_abierto"
    case porAbrir = "por_abrir"
    case proximamente
    case cerrada

    var label: String {
        switch self {
        case .abierta, .registroAbierto: Localization.scholarshipOpen
        case .porAbrir, .proximamente: Localization.scholarshipUpcoming
        case .cerrada: Localization.scholarshipClosed
        }
    }

    var color: Color {
        switch self {
        case .abierta, .registroAbierto: .green
        case .porAbrir, .proximamente: .orange
        case .cerrada: .red
        }
    }

    var sortPriority: Int {
        switch self {
        case .abierta, .registroAbierto: 0
        case .porAbrir, .proximamente: 1
        case .cerrada: 2
        }
    }
}

enum IPNScholarshipPeriodicidad: String, Codable, Sendable {
    case mensual
    case semestral
    case pagoUnico = "pago_unico"

    var label: String {
        switch self {
        case .mensual: Localization.monthly
        case .semestral: Localization.biannual
        case .pagoUnico: Localization.oneTimePayment
        }
    }
}

enum IPNScholarshipBeneficio: String, Codable, Sendable {
    case economico
    case especie
    case mixto

    var label: String {
        switch self {
        case .economico: Localization.economic
        case .especie: Localization.inKind
        case .mixto: Localization.mixed
        }
    }
}
