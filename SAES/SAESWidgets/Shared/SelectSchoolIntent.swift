import AppIntents
import WidgetKit

struct SchoolAppEntity: AppEntity {
    var id: String
    var name: String

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Escuela")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static let defaultQuery = SchoolEntityQuery()
}

struct SchoolEntityQuery: EntityQuery {
    func entities(for identifiers: [SchoolAppEntity.ID]) async throws -> [SchoolAppEntity] {
        let manifest = WidgetDataStore.shared.loadSchoolsManifest()
        return identifiers.compactMap { id in
            guard let info = manifest.first(where: { $0.schoolCode == id }) else { return nil }
            return SchoolAppEntity(id: info.schoolCode, name: info.schoolName)
        }
    }

    func suggestedEntities() async throws -> [SchoolAppEntity] {
        WidgetDataStore.shared.loadSchoolsManifest().map {
            SchoolAppEntity(id: $0.schoolCode, name: $0.schoolName)
        }
    }

    func defaultResult() async -> SchoolAppEntity? {
        try? await suggestedEntities().first
    }
}

struct SelectSchoolIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Seleccionar escuela"
    static let description: IntentDescription = "Elige la escuela de la que quieres ver el horario."

    @Parameter(title: "Escuela")
    var school: SchoolAppEntity?
}
