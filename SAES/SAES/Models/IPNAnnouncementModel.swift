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
    let expirado: Bool?

    var isExpired: Bool {
        if let expirado { return expirado }
        guard let expira, let date = Self.parseDate(expira) else { return false }
        return date < .now
    }

    var formattedFecha: String {
        Self.formatDate(fecha)
    }

    var formattedExpira: String? {
        guard let expira else { return nil }
        return Self.formatDate(expira)
    }

    private static func parseDate(_ string: String) -> Date? {
        let iso = string.contains("Z") || string.contains("+") ? string : string + "Z"
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = parser.date(from: iso) { return date }
        parser.formatOptions = [.withInternetDateTime]
        return parser.date(from: iso)
    }

    private static func formatDate(_ string: String) -> String {
        guard let date = parseDate(string) else { return string }
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dMMMM")
        return formatter.string(from: date)
    }
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
