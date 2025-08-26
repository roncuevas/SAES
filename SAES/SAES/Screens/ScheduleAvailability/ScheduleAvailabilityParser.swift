import Foundation

final class ScheduleAvailabilityParser: SAESParser {
    func getFields(_ data: Data) throws -> [ScheduleAvailabilityField: String] {
        let html = try self.convert(data)
        var dictionary: [ScheduleAvailabilityField: String] = [:]
        let fields = ScheduleAvailabilityField.allCases
        fields.forEach {
            guard let selectorID = $0.selector.idSelector else { return }
            if $0.selector.type == "select" {
                guard let select = try? html.select("#\(selectorID)").first() else { return }
                dictionary[$0] = try? select.child(0).val()
            } else {
                dictionary[$0] = try? html.select("#\(selectorID)").first()?.val().replacingOccurrences(of: " ", with: "+")
            }
        }
        return dictionary
    }

    func getOptions(data: Data, for fieldType: ScheduleAvailabilityField) throws -> [SAESSelector] {
        let html = try self.convert(data)
        guard let selectorID = fieldType.selector.idSelector else { return [] }
        guard let fieldElement = try? html.select("#\(selectorID)").first() else { return [] }
        return try fieldElement.children().map {
            SAESSelector(type: "option", value: try $0.val(), text: try $0.text())
        }
    }
}
