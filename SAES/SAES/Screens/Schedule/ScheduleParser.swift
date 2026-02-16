import Foundation
import SwiftSoup

struct ScheduleParser: SAESParser {
    private static let selectors: ScrapingSelectorsConfiguration.ScheduleSelectors = {
        // swiftlint:disable:next force_try
        let config = try! ConfigurationLoader.shared.load(
            ScrapingSelectorsConfiguration.self, from: "scraping_selectors"
        )
        return config.schedule
    }()

    func parseSchedule(_ data: Data) throws -> [ScheduleItem] {
        let document = try convert(data)

        guard let table = try Self.selectors.tableIDs
            .lazy.compactMap({ try? document.getElementById($0) }).first
        else { throw ScheduleError.noTableFound }

        let rows = try table.select("tr").array()
        guard rows.count > 1 else { throw ScheduleError.noTableFound }

        let headers = try rows[0].select("th").array().map { th in
            try th.text()
                .lowercased()
                .replacingOccurrences(of: "\n", with: " ")
                .replacingOccurrences(of: " ", with: "_")
                .folding(options: .diacriticInsensitive, locale: .init(identifier: "es"))
        }

        var items: [ScheduleItem] = []
        for row in rows[1...] {
            let cells = try row.select("td").array()
            var dict: [String: String] = [:]
            for (index, cell) in cells.enumerated() where index < headers.count {
                dict[headers[index]] = try cell.text().trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let hasContent = dict.values.contains { value in
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmed.isEmpty && trimmed != "-"
            }
            guard hasContent else { continue }
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            let item = try JSONDecoder().decode(ScheduleItem.self, from: jsonData)
            items.append(item)
        }
        return items
    }
}
