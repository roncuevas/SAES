import Foundation

final class SAESViewStatesParser: SAESParser {
    func parse(_ data: Data) throws -> [SAESViewStates: String] {
        let html = try self.convert(data)
        var dictionary: [SAESViewStates: String] = [:]
        SAESViewStates.allCases.forEach {
            dictionary[$0] = try? html.select("#\($0.rawValue)").first()?.val()
        }
        return dictionary
    }
}
