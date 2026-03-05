import Foundation
import SwiftUI

struct IPNAnnouncementResponse: Codable, Sendable {
    let success: Bool
    let data: IPNAnnouncementData
}

struct IPNAnnouncementData: Codable, Sendable {
    let total: Int
    let anuncios: [IPNAnnouncement]
}

struct IPNAnnouncement: Codable, Identifiable, Sendable {
    let id: String
    let importancia: Int
    let tipo: IPNAnnouncementType
    let titulo: String
    let descripcion: String
    let fecha: String
    let expira: String?
    let escuelas: [String]?
    let nivel: String?
    let url: String?
}

enum IPNAnnouncementType: String, Codable, Sendable, CaseIterable {
    case informativo
    case mantenimiento
    case academico
    case urgente

    var label: String {
        switch self {
        case .informativo: Localization.announcementInformative
        case .mantenimiento: Localization.announcementMaintenance
        case .academico: Localization.announcementAcademic
        case .urgente: Localization.announcementUrgent
        }
    }

    var color: Color {
        switch self {
        case .informativo: .blue
        case .mantenimiento: .orange
        case .academico: .purple
        case .urgente: .red
        }
    }

    var icon: String {
        switch self {
        case .informativo: "info.circle.fill"
        case .mantenimiento: "wrench.and.screwdriver.fill"
        case .academico: "book.fill"
        case .urgente: "exclamationmark.triangle.fill"
        }
    }

    var sortPriority: Int {
        switch self {
        case .urgente: 0
        case .academico: 1
        case .mantenimiento: 2
        case .informativo: 3
        }
    }
}
