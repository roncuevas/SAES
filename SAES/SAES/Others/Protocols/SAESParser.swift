import Foundation
import SwiftSoup

protocol SAESParser {
    func selectorVariants(element: Element, _ selector: String) throws -> Element
    func convert(_ data: Data) throws -> Document
}

extension SAESParser {
    func selectorVariants(element: Element, _ selector: String) throws -> Element {
        let escomSelector: String = selector.replacingOccurrences(of: "ctl00_", with: "")
        if let element = try? element.select(selector).first() {
            return element
        } else if let element = try? element.select(escomSelector).first() {
            return element
        } else {
            throw SAESParserError.nodeNotFound
        }
    }

    func convert(_ data: Data) throws -> Document {
        guard let string = String(data: data, encoding: .utf8)
        else { throw SAESParserError.dataIsNotUTF8 }
        return try SwiftSoup.parse(string)
    }
}
