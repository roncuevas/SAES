import Foundation
import SwiftSoup

final class ScheduleAvailabilityViewModel {
    private var dataSource: SAESDataSource = ScheduleAvailabilityDataSource()
    private var parser: ScheduleAvailabilityParser = ScheduleAvailabilityParser()
    private let selectors: [String] = ["__VIEWSTATE", "__EVENTTARGET", "__EVENTARGUMENT", "__LASTFOCUS", "__VIEWSTATEGENERATOR", "__VIEWSTATEENCRYPTED", "__EVENTVALIDATION"]
    let fields: [String: String?] = ["filtroCarrera": "ctl00_mainCopy_Filtro_cboCarrera",
                                     "filtroTurno": "ctl00_mainCopy_Filtro_cboTurno",
                                     "filtroPeriodos": "ctl00_mainCopy_Filtro_lsNoPeriodos",
                                     "filtroPlanStudy": "ctl00_mainCopy_Filtro_cboPlanEstud"]

    func getData() async {
        do {
            let data = try await dataSource.fetch()
            let values = try parser.getStates(data, selectors: selectors)
        } catch {
            print(error)
        }
    }
}

final class ScheduleAvailabilityDataSource: SAESDataSource {
    func fetch() async throws -> Data {
        guard let url = URL(string: URLConstants.scheduleAvailability.value)
        else { throw URLError(.badURL) }
        return try await SAESFetcher(url: url)
    }
}

final class ScheduleAvailabilityParser: SAESParser {
    func getStates(_ data: Data, selectors: [String]) throws -> [String: String?] {
        let html = try self.convert(data)
        var dictionary: [String: String?] = [:]

        selectors.forEach {
            dictionary[$0] = try? html.select("#\($0)").first()?.val()
        }

        return dictionary
    }
}
