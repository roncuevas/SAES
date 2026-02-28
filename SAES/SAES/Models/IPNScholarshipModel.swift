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
    let periodicidad: IPNScholarshipPeriodicidad
    let tipoBeneficio: IPNScholarshipBeneficio
    let url: String?
    let montoMin: Double?
    let montoMax: Double?

    enum CodingKeys: String, CodingKey {
        case id, titulo, descripcion, status, fecha, monto, periodicidad, url
        case fechaLabel = "fecha_label"
        case tipoBeneficio = "tipo_beneficio"
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
}

enum IPNScholarshipPeriodicidad: String, Codable, Sendable {
    case mensual
    case semestral
    case pagoUnico = "pago_unico"
}

enum IPNScholarshipBeneficio: String, Codable, Sendable {
    case economico
    case especie
    case mixto
}
