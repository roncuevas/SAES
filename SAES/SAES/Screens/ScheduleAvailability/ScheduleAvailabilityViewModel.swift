import Foundation
import SwiftSoup

final class ScheduleAvailabilityViewModel {
    private var dataSource = ScheduleAvailabilityDataSource()
    private var parser: ScheduleAvailabilityParser = ScheduleAvailabilityParser()
    private let selectors: [String] = [
        "__EVENTTARGET",
        "__EVENTARGUMENT",
        "__LASTFOCUS",
        "__VIEWSTATE",
        "__VIEWSTATEGENERATOR",
        "__EVENTVALIDATION",
    ]

    func getData() async {
        do {
            let data = try await dataSource.fetch()
            let states = try parser.getStates(data, selectors: selectors)
            let values = try parser.getFields(data)
            try await dataSource.send(states: states, selectors: selectors, values: values)
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

    func send(states: [String: String],
              selectors: [String],
              values: [ScheduleAvailabilityFields: String]) async throws -> Data {
        guard let url = URL(string: URLConstants.scheduleAvailability.value)
        else { throw URLError(.badURL) }
        let cookies: String = LocalStorageManager.loadLocalCookies(UserDefaults.schoolCode)
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(cookies, forHTTPHeaderField: "Cookie")
        var bodyParameters: [String] = []
        states.forEach { (key: String, value: String) in
            guard let value = states[key] else { return }
            let text = "\(key)=\(value)"
            bodyParameters.append(text)
        }
        values.forEach { (key: ScheduleAvailabilityFields, value: String) in
            guard let name = key.selector.name else { return }
            let text = "\(name)=\(value)"
            bodyParameters.append(text)
        }
        request.httpBody = formURLEncode(bodyParameters.joined(separator: "&"))
            .data(using: .utf8)

        return try await URLSession.shared.data(for: request).0
    }

    func formURLEncode(_ query: String) -> String {
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._*")

        return query
            .split(separator: "&")
            .map { pair -> String in
                let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
                let key = parts.first ?? ""
                let value = parts.count > 1 ? parts[1] : ""

                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value

                // Convertir %20 en "+"
                let fixedValue = encodedValue.replacingOccurrences(of: "%20", with: "+")
                return "\(encodedKey)=\(fixedValue)"
            }
            .joined(separator: "&")
    }
}

final class ScheduleAvailabilityParser: SAESParser {
    func getStates(_ data: Data, selectors: [String]) throws -> [String: String] {
        let html = try self.convert(data)
        var dictionary: [String: String] = [:]
        selectors.forEach {
            dictionary[$0] = try? html.select("#\($0)").first()?.val()
        }
        return dictionary
    }

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

struct SAESSelector {
    let type: String
    var id: String?
    var name: String?
}

enum ScheduleAvailabilityFields: CaseIterable {
    case career
    case shift
    case periods
    case studyPlan
    case schoolPeriodGroup
    case sequences
    case visualize

    var selector: SAESSelector {
        return switch self {
        case .career:
            SAESSelector(type: "select", id: "ctl00_mainCopy_Filtro_cboCarrera", name: "ctl00$mainCopy$Filtro$cboCarrera")
        case .shift:
            SAESSelector(type: "select", id: "ctl00_mainCopy_Filtro_cboTurno", name: "ctl00$mainCopy$Filtro$cboTurno")
        case .periods:
            SAESSelector(type: "select", id: "ctl00_mainCopy_Filtro_lsNoPeriodos", name: "ctl00$mainCopy$Filtro$lsNoPeriodos")
        case .studyPlan:
            SAESSelector(type: "select", id: "ctl00_mainCopy_Filtro_cboPlanEstud", name: "ctl00$mainCopy$Filtro$cboPlanEstud")
        case .schoolPeriodGroup:
            SAESSelector(type: "input", id: "ctl00_mainCopy_optActual", name: "ctl00$mainCopy$GroupPeriodoEscolar")
        case .sequences:
            SAESSelector(type: "select", id: "ctl00_mainCopy_lsSecuencias", name: "ctl00$mainCopy$lsSecuencias")
        case .visualize:
            SAESSelector(type: "input", id: "ctl00_mainCopy_cmdVisalizar", name: "ctl00$mainCopy$cmdVisalizar")
        }
    }
}
