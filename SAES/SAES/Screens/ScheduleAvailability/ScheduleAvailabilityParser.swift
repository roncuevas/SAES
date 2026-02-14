import Foundation

final class ScheduleAvailabilityParser: SAESParser, Sendable {
    private static let selectors: ScrapingSelectorsConfiguration.ScheduleAvailabilitySelectors = {
        // swiftlint:disable:next force_try
        let config = try! ConfigurationLoader.shared.load(ScrapingSelectorsConfiguration.self, from: "scraping_selectors")
        return config.scheduleAvailability
    }()

    func getFields(_ data: Data) throws -> [ScheduleAvailabilityField: String] {
        let html = try self.convert(data)
        var dictionary: [ScheduleAvailabilityField: String] = [:]
        let fields = ScheduleAvailabilityField.allCases
        fields.forEach {
            guard let selectorID = $0.selector.selector else { return }
            if $0.selector.type == "select" {
                guard let select = try? html.select(selectorID).first() else { return }
                dictionary[$0] = try? select.child(0).val()
            } else {
                dictionary[$0] = try? html.select(selectorID).first()?.val().replacingOccurrences(of: " ", with: "+")
            }
        }
        return dictionary
    }

    func getOptions(data: Data, for fieldType: ScheduleAvailabilityField) throws -> [SAESSelector] {
        let html = try self.convert(data)
        guard let selectorID = fieldType.selector.selector else { return [] }
        guard let fieldElement = try? html.select(selectorID).first() else { return [] }
        return try fieldElement.children().map {
            SAESSelector(type: "option", selector: try? $0.cssSelector(), value: try $0.val(), text: try $0.text())
        }
    }

    func getSubjects(data: Data) throws -> [SAESScheduleSubject] {
        let html = try self.convert(data)
        let tableElement = try html.select(Self.selectors.tableSelector)
        let rows = try tableElement.select("tr")
        return try rows.compactMap { row in
            guard row.children().count == Self.selectors.expectedColumnCount else { return nil }
            guard row.children().contains(where: { $0.tagName() == "td" }) else { return nil }
            return SAESScheduleSubject(
                group: try row.child(0).text(),
                name: try row.child(1).text(),
                teacher: try row.child(2).text(),
                schedule: (5...10).map {
                    return SAESDailySchedule(day: SAESDays(rawValue: $0 - 5),
                                             time: try? row.child($0).text())
                },
                building: try row.child(3).text(),
                classroom: try row.child(4).text())
        }
    }
}
