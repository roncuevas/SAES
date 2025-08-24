import Foundation

final class ScheduleAvailabilityParser: SAESParser {
    func getFields(_ data: Data) throws -> [ScheduleAvailabilityFields: String] {
        let html = try self.convert(data)
        var dictionary: [ScheduleAvailabilityFields: String] = [:]
        let fields = ScheduleAvailabilityFields.allCases
        fields.forEach {
            guard let selectorID = $0.selector.id else { return }
            if $0.selector.type == "select" {
                let select = try? html.select("#\(selectorID)").first()
                guard let select else { return }
                dictionary[$0] = try? select.child(0).val()
            } else {
                dictionary[$0] = try? html.select("#\(selectorID)").first()?.val().replacingOccurrences(of: " ", with: "+")
            }
        }
        return dictionary
    }
}
