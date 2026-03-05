import Foundation

enum ScheduleAvailabilityField: String, CaseIterable {
    case career
    case shift
    case periods
    case studyPlan
    case schoolPeriodGroup
    case sequences
    case visualize

    private static let fieldSelectors = ScrapingSelectorsConfiguration.shared.scheduleAvailability.fields

    var selector: SAESSelector {
        guard let field = Self.fieldSelectors[rawValue] else {
            return SAESSelector(type: "", selector: nil)
        }
        return SAESSelector(type: field.type, selector: field.selector)
    }

    var name: String {
        Self.fieldSelectors[rawValue]?.postName ?? ""
    }
}
